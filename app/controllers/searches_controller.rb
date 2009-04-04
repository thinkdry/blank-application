class SearchesController < ApplicationController
	
  acts_as_ajax_validation
  
  def index
#		@hide_full_text_search = true
		dodo
		@results = @results.map{ |e| e.accepts_show_for?(@current_user) ? e : nil }#.paginate(:page => params[:page], :per_page => 20)
  end

	def print_advanced
		render :partial => 'advanced_search', :locals => { :category => params[:search][:category] }
	end
  
  private
	def dodo
		# Initialisation : default params
		if !params[:search][:models]
			if (params[:search][:category] == 'all')
				params[:search][:models] = available_items_list+['user']+['workspace']
			elsif (params[:search][:category] == 'item')
				params[:search][:models] = available_items_list
			else
				params[:search][:models] = params[:search][:category]
			end
		end
		params[:search][:filter_name] ||= 'created_at'
		params[:search][:filter_way] ||= 'desc'
		params[:search][:filter_limit] ||= 15

		@search = Search.new(params[:search])

		results = []
		if params[:search][:models].size == 1
			model_const = params[:search][:models].first.classify.constantize
			if !params[:search][:full_text_field].blank? && (params[:search][:full_text_field] != I18n.t('layout.search.search_label'))
				results += model_const.full_text_with_xapian(params[:search][:full_text_field]).advanced_on_fields(@search.conditions).filtering_on_field(params[:search][:filter_name], params[:search][:filter_way], params[:search][:filter][:limit])
			else
				results += model_const.advanced_on_fields(@search.conditions).filtering_on_field(params[:search][:filter_name], params[:search][:filter_way], params[:search][:filter_limit])
			end
		else
			params[:search][:models].each do |model_name|
				model_const = model_name.classify.constantize
				if !params[:search][:full_text_field].blank? && (params[:search][:full_text_field] != I18n.t('layout.search.search_label'))
					results += model_const.full_text_with_xapian(params[:search][:full_text_field]).advanced_on_fields(@search.conditions)
				else
					results += model_const.advanced_on_fields(@search.conditions)
				end
				results = results.sort do |x, y|
					if (params[:search][:filter_way] == 'desc')
						x.send(params[:search][:filter_name].to_sym) <=> y.send(params[:search][:filter_name].to_sym)
					else
						y.send(params[:search][:filter_name].to_sym) <=> x.send(params[:search][:filter_name].to_sym)
					end
				end # TODO limit
			end
		end
		@results = results
	end


  def advanced_search
    @hide_full_text_search = true
    @header = 'advanced_search_fields'
    @search = Search.new(params[:search])
    render(:action => :new) and return unless @search.valid?
    @items = GenericItem.consultable_by(@current_user.id).all(:conditions => @search.attributes.delete_if { |k, v| v.nil? })
  end
  
  def full_text_search
    @header = 'full_text_search_header'
    filter = 'created_at'
    filter = params[:filter].to_s unless params[:filter].nil?
    if params[:model] && !params[:model].empty?
      models = [params[:model].constantize]
    else
      models = available_items_list.map{|e| e.classify.constantize}
    end
    search = ActsAsXapian::Search.new(models, params[:search], :limit => 50, :sort_by_prefix => "#{filter}", :sort_by_ascending => true)
    @items = search.results.collect { |r| r[:model]}.delete_if do |e|
      !e.accepts_show_for?(@current_user)
    end
    @correction = search.spelling_correction
    @similar_items = ActsAsXapian::Similar.new(models, @items, :limit =>5).results.collect {|r| r[:model]}
	end

	def do_search_on_item
		@search = Search.new(params[:search])
    # to include inside the form
		@search.filter = params[:search][:filter] || 'created_at'
		@search.sort = params[:search][:sort] || 'DESC'
		@search.limit = params[:search][:limit] || '50'
		# Models to check in Xapian index and GenericItem too
		if params[:search][:category] == 'item'
			if params[:item_types]
				@search.models = params[:item_types].keys.map{ |k| k.camelize.classify.constantize }.join(',')
				@hide_full_text_search = true
			else
				@search.models = available_items_list.map{ |e| e.camelize.classify.constantize }.join(',')
			end
		else 
			@search.models = params[:search][:category].camelize
		end
		#
		p @search
		p @search.models.split(',')
		# Full text search, ordered, return Array of Items
		if !params[:search][:full_text_field].blank?
			@header = 'full_text_search_header'
			search = ActsAsXapian::Search.new(@search.models.split(','), @search.full_text_field, :limit => @search.limit.to_i, :sort_by_prefix => @search.filter, :sort_by_ascending => true)
			@xapian = search.results.collect{ |r| r[:model] }
			@corrections = search.spelling_correction
			#@similar_items = ActsAsXapian::Similar.new(@search.models.split(','), @xapian, :limit => 5).results.collect {|r| r[:model]}
		end
		# Advanced search, ordered, return Array of GenericItem
		if params[:search][:advanced] == 'true'
			@cond = {}
			@cond.merge!({:item_type_equals => @search.models.split(',')}) unless @search.models.blank?
			@cond.merge!({:user_name_equals => @search.creator}) unless @search.creator.blank?
			@cond.merge!({:created_after => @search.created_after}) unless @search.created_after.blank?
			@cond.merge!({:created_before => @search.created_before}) unless @search.created_before.blank?
			@advanced = GenericItem.all(:conditions => @cond, :order => 'generic_items.'+@search.filter+' '+@search.sort, :limit => @search.limit.to_i)
		end
		if @xapian
			if @advanced
				@items = []
			else
				@items = @xapian
			end
		else
			@items = @advanced || []
		end
		p @items
		# Return just the element consultable
		@items = @items.map{ |e| e.accepts_show_for?(@current_user) ? e : nil }
	end

	
end
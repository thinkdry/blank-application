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
				params[:search][:models] = [params[:search][:category]]
			end
		end
		params[:search][:filter_name] ||= 'created_at'
		params[:search][:filter_way] ||= 'desc'
		params[:search][:filter_limit] ||= 15

		@search = Search.new(params[:search])

		results = []
		if params[:search][:models].size == 1
			if params[:search][:full_text_field]
				params[:search][:filter_name] ||= 'weight'
			end
			model_const = params[:search][:models].first.classify.constantize
			if !params[:search][:full_text_field].blank? && (params[:search][:full_text_field] != I18n.t('layout.search.search_label'))
				results += model_const.full_text_with_xapian(params[:search][:full_text_field]).advanced_on_fields(@search.conditions).filtering_on_field(params[:search][:filter_name], params[:search][:filter_way], params[:search][:filter_limit])
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
#		@correction = search.spelling_correction
#    @similar_items = ActsAsXapian::Similar.new(models, @items, :limit =>5).results.collect {|r| r[:model]}
	end

end
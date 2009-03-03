class SearchesController < ApplicationController
	
  acts_as_ajax_validation
  
  def new
    @hide_full_text_search = true
    @search = Search.new
		@result = nil
  end
  
  def index
		@items ||= params[:items]
		if params[:search][:category]=='item' && @items.nil?
			do_search_on_item
		end
		@items = @items.paginate(:page => params[:page])
  end

  def filter
    full_text_search
    @items = @items.paginate(:page => params[:page])
    render :partial => 'result', :collection => @items
  end
  
  private
	def do_search_on_item
		@search = Search.new(params[:search])
		#
		if params[:item_types]
			@search.models = params[:item_types].keys.map{ |k| k.camelize.classify.constantize }.join(',')
			@hide_full_text_search = true
		else
			@search.models = available_items_list.map{ |e| e.camelize.classify.constantize }.join(',')
			p @search.models
		end
		# FULL TEXT
		if !params[:search][:full_text_field].blank?
			@header = 'full_text_search_header'
			search = ActsAsXapian::Search.new(@search.models, @search.full_text_field, :limit => 30)
			@xapian = search.results.select{ |r| r[:model] }
			@corrections = search.spelling_correction
		else
			@xapian = nil
		end
		# ADVANCED condition
		@cond = {}
		@cond.merge!({:item_type_equals => @search.models.split(',')}) unless @search.models.blank?
		@cond.merge!({:user_name_equals => @search.creator}) unless @search.creator.blank?
		@cond.merge!({:created_after => @search.created_after}) unless @search.created_after.blank?
		@cond.merge!({:created_before => @search.created_before}) unless @search.created_before.blank?
		# Items to GenericItems = BULLSHIT
		if @xapian.nil?
			@items = GenericItem.consultable_by(@current_user.id).rated(:conditions => @cond)
		else
			@xapian = @xapian.map{ |e| GenericItem.find(:item_type => e.class.to_s, :id => e.id) }
			p @xapian
			@items = @xapian.consultable_by(@current_user.id).all(:conditions => @cond)
		end
		# Object
		#@similar_items = ActsAsXapian::Similar.new(@search.models, @items, :limit =>5).results.collect {|r| r[:model]}
  end

	
end
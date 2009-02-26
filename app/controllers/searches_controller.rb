class SearchesController < ApplicationController
  acts_as_ajax_validation
  
  def new
    @hide_full_text_search = true
    @search = Search.new
    # By default, search into every type of items
    @search.item_type_equals = %W(Article Image Video Audio Publication CmsFile FeedSource)
  end
  
  def show
    params[:search].is_a?(Hash) ? advanced_search : full_text_search
    @items = @items.paginate(:page => params[:page])
  end

  def filter
    full_text_search
    @items = @items.paginate(:page => params[:page])
    render :partial => 'result', :collection => @items
  end
  
  private
  def advanced_search
    @hide_full_text_search = true
    @header = 'advanced_search_fields'
    @search = Search.new(params[:search])
    render(:action => :new) and return unless @search.valid?
    @items = GenericItem.consultable_by(@current_user.id).all(:conditions => @search.attributes.delete_if { |k, v| v.nil? })
  end
  
  def full_text_search
    @header = 'full_text_search_header'
    filter ='created'
    filter =params[:filter] if !params[:filter].nil?
    if params[:model] && !params[:model].empty?
      models = [params[:model].constantize]
      gitem=GenericItem.consultable_by(@current_user.id).send(params[:model].downcase.pluralize).send(filter).collect{|l| l.id}
    else
      models = [Article, CmsFile, Audio, Image, Publication, Video, FeedSource]
      gitem=GenericItem.consultable_by(@current_user.id).send(filter).all.collect{|l| l.id}
    end
        search = ActsAsXapian::Search.new(models, params[:search], :limit => 50)
        search_results = search.results.select do |r|
          gitem.include?(r[:model].id)
        end
        @items = search_results.collect { |r| r[:model]}.delete_if do |e|
          !permit?("consultation of item", { :item => e
            })
        end
    @corrections = search.spelling_correction
    @similar_items = ActsAsXapian::Similar.new(models, @items, :limit =>5).results.collect {|r| r[:model]}
  end
end
class SearchesController < ApplicationController
  def new
    @hide_full_text_search = true
    @search = Search.new
    # By default, search into every type of items
    @search.item_type_equals = %W(Article Image Video Audio Publication ArticFile)
  end
  
  def show
    params[:search].is_a?(Hash) ? advanced_search : full_text_search
    @items = @items.paginate(:page => params[:page])
  end
  
  private
  def advanced_search
    @hide_full_text_search = true
    @header = 'advanced_search_fields'
    @search = Search.new(params[:search])
    render(:action => :new) and return unless @search.valid?
    @items = GenericItem.all(:conditions => @search.attributes.delete_if { |k, v| v.nil? })
  end
  
  def full_text_search
    @header = 'full_text_search_header'
    
    if params[:model] && !params[:model].empty?
      models = [params[:model].constantize]
    else
      models = [Article, ArticFile, Audio, Image, Publication, Video]
    end
    
    search = ActsAsXapian::Search.new(models, params[:search], :limit => 300)
    @items = search.results.collect { |r| r[:model] }.delete_if do |e|
      !permit?("consultation of item", { :item => e })
    end
  end
end

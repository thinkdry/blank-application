class SearchesController < ApplicationController
  def new
    @hide_full_text_search = true
  end
  
  def show
    params[:search].is_a?(Hash) ? advanced_search : full_text_search
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
    search = ActsAsXapian::Search.new(
       [Article, ArticFile, Audio, Image, Publication, Video],
       params[:search], :limit => 20)
    @items = search.results.collect { |r| r[:model] }
  end
end

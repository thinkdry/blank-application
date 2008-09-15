class SearchesController < ApplicationController
  def new
    # @search = GenericItem.new_search(params[:search])
  end
  
  def show
    @search = Search.new(params[:search])
    render(:action => :new) and return unless @search.valid?
    @items = GenericItem.all(:conditions => params[:search])
  end
end

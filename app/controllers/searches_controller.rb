class SearchesController < ApplicationController
  def new
    # @search = GenericItem.new_search(params[:search])
  end
  
  def show
    @items = GenericItem.all(:conditions => params[:search])
  end
end

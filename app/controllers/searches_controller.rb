class SearchesController < ApplicationController
  def new
  end
  
  def show
    @search = Search.new(params[:search])
    render(:action => :new) and return unless @search.valid?
    @items = GenericItem.all(:conditions => @search.attributes.delete_if { |k, v| v.nil? })
  end
end

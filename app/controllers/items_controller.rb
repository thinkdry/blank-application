class ItemsController < ApplicationController
  def index
  end

  def display_item_in_pop_up
    @object = (params[:item_type].classify.constantize).find(:all)
    render :layout => 'pop_up', :object => @object
  end
end
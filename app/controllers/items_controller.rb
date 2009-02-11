class ItemsController < ApplicationController
  def index
  end

  def display_item_in_pop_up
    if params[:item_type] == "all"
      @object = GenericItem.consultable_by(@current_user.id)
    else
      @object = (params[:item_type].classify.constantize).find(:all, :conditions =>{ :user_id => @current_user.id}, :order => "updated_at DESC" )
    end
    render :layout => 'pop_up', :object => @object
  end
end
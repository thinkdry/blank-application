class ItemsController < ApplicationController
  def index
  end
  
  def method_missing method_name, *args
    item_type, item_id = params[:item_type], params[:id].to_i
    raise "item_type and id params expected" if item_type.nil? || item_id.nil?
    redirect_to(params.merge(:controller => item_type.downcase))
  end
end
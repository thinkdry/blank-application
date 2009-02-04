class ItemsController < ApplicationController
  def index
  end

  def display_item_in_pop_up
    render :layout => 'pop_up'
  end
end
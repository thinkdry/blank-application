class ItemsController < ApplicationController
  before_filter { |controller| controller.session[:menu] = 'items' }
  
  def index
  end
end
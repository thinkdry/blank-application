class AdminController < ApplicationController
  before_filter { |controller| controller.session[:menu] = nil }
  permit 'admin'
  
  def index
  end
end

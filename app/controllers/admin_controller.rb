class AdminController < ApplicationController
  permit 'admin'
  
  def index
  end
end

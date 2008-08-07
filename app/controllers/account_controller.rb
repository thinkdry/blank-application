class AccountController < ApplicationController
  before_filter { |controller| controller.session[:menu] = 'account' }
  
  def index
  end
  
  def profile
    redirect_to user_path(current_user)
  end
  
  def contents
  end
end

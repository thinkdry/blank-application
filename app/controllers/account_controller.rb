class AccountController < ApplicationController
  def index
  end
  
  def profile
    render_component(:controller => 'users', :action => 'show', :id => current_user)
  end
  
  def contents
  end
end

class AccountController < ApplicationController
  before_filter { |controller| controller.session[:menu] = 'account' }
  
  def index
    @latest_items=GenericItem.latest
    @latest_users=User.latest
    @latest_pubmed=PubmedItem.latest
    @latest_ws=Workspace.latest
   # @latest=GenericItem.consultable_by(current_user)
  end
  
  def profile
    redirect_to user_path(current_user)
  end
  
  def contents
  end
end

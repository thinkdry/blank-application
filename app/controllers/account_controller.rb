class AccountController < ApplicationController 
  # Root page ('/')
  def index
    @latest_items = GenericItem.consultable_by(current_user).latest
    @latest_users = User.latest
    @latest_pubmed = current_user.pubmed_items.latest
    @latest_ws = Workspace.latest
  end
end

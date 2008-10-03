class AccountController < ApplicationController 
  # Root page ('/')
  def index
    @latest_items = GenericItem.latest
    @latest_users = User.latest
    @latest_pubmed = PubmedItem.latest
    @latest_ws = Workspace.latest
  end
end

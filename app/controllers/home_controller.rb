class HomeController < ApplicationController 
  # Root page ('/')
  def index
    @latest_items = GenericItem.consultable_by(current_user).latest
    @latest_users = User.latest
    @latest_feeds = current_user.feed_items.latest
    @latest_ws = Workspace.latest
		@accordion=[@latest_items,@latest_users,@latest_feeds,@latest_ws]
  end
end

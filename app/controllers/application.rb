# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :is_logged?
	
	include AuthenticatedSystem
	include ActsAsItem::UrlHelpers
	
	def is_logged?
    if logged_in?
      return true
    else
      redirect_to login_path
    end
  end
	
end

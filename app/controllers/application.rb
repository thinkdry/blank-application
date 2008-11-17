# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :is_logged?
	before_filter :set_locale
		
	include AuthenticatedSystem
	include ActsAsItem::UrlHelpers
	
	def is_logged?
    if logged_in?
      return true
    else
      redirect_to login_path
    end
  end
	

  private
  def set_locale
    I18n.locale = params[:locale] or session[:locale] or I18n.default_locale
  end
	
	
end

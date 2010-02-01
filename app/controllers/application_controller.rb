class ApplicationController < ActionController::Base

  # Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem
  # Captcha Management
	include YacaphHelper
  # Configuration
  include Configuration
	
	helper :yacaph, :websites

  before_filter :get_configuration
	
end


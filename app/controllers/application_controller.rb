class ApplicationController < ActionController::Base

  # Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem
  # Captcha Management
	include YacaphHelper
  # Configuration
  include Configuration

  before_filter :get_configuration
	
	helper :yacaph, :websites

	
end


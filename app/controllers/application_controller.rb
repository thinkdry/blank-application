class ApplicationController < ActionController::Base

  # Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem
  # Captcha Management
	include YacaphHelper
	
	helper :yacaph, :websites
	
end


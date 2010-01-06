class ApplicationController < ActionController::Base

# Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem
	
	before_filter :logged_in?

end


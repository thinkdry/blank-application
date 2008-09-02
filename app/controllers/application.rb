# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :is_logged?
	
	helper_method :current_workspace
	
	include AuthenticatedSystem
	
	def is_logged?
    if logged_in?
      return true
    else
      redirect_to login_path
    end
  end
  
  def current_workspace
    return @workspace if @workspace
    return @current_object if @current_object && @current_object.class == Workspace
    if params['workspace_id']
      @workspace = Workspace.find(params['workspace_id'].to_i)
      return @workspace
    end
    nil
  end
	
end

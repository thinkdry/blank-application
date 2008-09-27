class AdminController < ApplicationController
  
	#before_filter { |controller| controller.session[:menu] = nil }
  #permit 'admin'
	
	acts_as_ajax_validation
  
	def index
		@current_object = current_user
		@workspace = Workspace.new
		@workspaces = if (current_user.system_role == "Admin")
		  Workspace.find(:all)
	  else
	    Workspace.administrated_by(current_user) + Workspace.moderated_by(current_user)
    end
  end
	
end

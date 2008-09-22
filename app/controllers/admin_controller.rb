class AdminController < ApplicationController
  
	#before_filter { |controller| controller.session[:menu] = nil }
  #permit 'admin'
	
	acts_as_ajax_validation
  
	def index
		@current_object = current_user
		@workspace = Workspace.new
  end
	
end

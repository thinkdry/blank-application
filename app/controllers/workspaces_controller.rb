class WorkspacesController < ApplicationController
	
	acts_as_ajax_validation
	before_filter { |controller| controller.session[:menu] = nil }

  make_resourceful do
    actions :all
    
    before :show do
      session[:menu] = 'workspaces'
    end
    
    before :update do
      # Hack. Allow deletion of all assigned users (with roles).
      params["workspace"]["existing_user_attributes"] ||= {}
    end
	end
	
end
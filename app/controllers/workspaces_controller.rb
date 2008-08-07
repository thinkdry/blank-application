class WorkspacesController < ApplicationController
	
	acts_as_ajax_validation

  make_resourceful do
    actions :all
    before :update do
      # Hack. Allow deletion of all assigned users (with roles).
      params["workspace"]["existing_user_attributes"] ||= {}
    end
	end
	
end
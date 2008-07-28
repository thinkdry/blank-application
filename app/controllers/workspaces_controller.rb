class WorkspacesController < ApplicationController
	
	acts_as_ajax_validation

  make_resourceful do
    actions :all
    before :update do
      params["workspace"]["existing_user_attributes"] ||= {}
    end
	end
	
end
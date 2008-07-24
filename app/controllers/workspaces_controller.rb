class WorkspacesController < ApplicationController
	
	acts_as_ajax_validation

  make_resourceful do
    actions :all
	end
 
		
end
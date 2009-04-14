class GroupsController < ApplicationController

  acts_as_ajax_validation
  acts_as_item do

    after :create, :update do
      @group.group_people(params[:selected_Options],current_user)
    end
  end
	
end

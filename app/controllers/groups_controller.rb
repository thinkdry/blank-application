class GroupsController < ApplicationController

  acts_as_ajax_validation

  make_resourceful do
    actions :all

    after :create, :update do
      @group.group_people = params[:selected_Options]
    end
  end
end

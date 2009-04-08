class GroupsController < ApplicationController

  before_filter :get_groups, :only=>[:index,:ajax_index]
  acts_as_ajax_validation

  PER_PAGE = 10

  make_resourceful do
    actions :show, :create, :new, :edit, :update, :destroy

    after :create, :update do
      @group.group_people = params[:selected_Options]
    end
    
  end

  def index

  end

  def ajax_index
    
    render :partial=> 'groups' ,:layout=>false
  end

  private
  def get_groups
    @groups = Group.paginate(
      :page => params[:page],
      :order => :title,
      :per_page => PER_PAGE
    )
  end
end

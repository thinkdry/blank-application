class WorkspacesController < ApplicationController
  acts_as_ajax_validation

  make_resourceful do
    actions :show, :create, :new, :edit, :update
    
    before :show do
      permit "consultation of current_object"
      params[:id] ||= params[:workspace_id]
    end
        
    before :create do
      @current_object.creator = @current_user
    end
    
    before :update do
      permit "edition of current_object"
      # Hack. Permit deletion of all assigned users (with roles).
      params["workspace"]["existing_user_attributes"] ||= {}
    end
  end

  def add_new_user
    @user = User.find_by_login(params[:user_login])
    @uw = UsersWorkspace.new
    @uw.role_id = params[:user_role]
    @uw.user = @user
    render :update do |page|
      page.insert_html :bottom, 'users', :partial => 'user',  :object => @uw
    end
  end
  
  def current_object
    @current_object ||= @workspace =
      if params[:id]
        Workspace.find(params[:id])
      elsif params[:workspace_id]
        Workspace.find(params[:workspace_id])
      else
        nil
      end
  end
 
end
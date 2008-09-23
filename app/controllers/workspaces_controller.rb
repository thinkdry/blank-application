class WorkspacesController < ApplicationController
	
  acts_as_ajax_validation
  before_filter { |controller| controller.session[:menu] = nil }

  make_resourceful do
    actions :all
    
    before :show do
      session[:menu] = 'workspaces'
    end
    
    before :index do
      session[:menu] = 'items'
    end
    
    before :create do
      @current_object.creator = @current_user
    end
    
    before :update do
      # Hack. Permit deletion of all assigned users (with roles).
      params["workspace"]["existing_user_attributes"] ||= {}
    end
    
    before :index do
    @current_objects = current_objects.paginate(
        :page => params[:page],
          			:order => :title,
				:per_page => 2
			)
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
 
end
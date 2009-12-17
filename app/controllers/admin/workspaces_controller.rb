class Admin::WorkspacesController < Admin::ApplicationController

	# Mixin method implementing ajax validation for that controller
  acts_as_ajax_validation

	# Mixin setting the permission for that controller (see lib/acts_as_authorizable.rb for more)
	acts_as_authorizable(
		:actions_permissions_links => {
					'new' => 'new',
					'create' => 'new',
					'edit' => 'edit',
					'update' => 'edit',
					'show' => 'show',
					'rate' => 'rate',
					'add_comment' => 'comment',
					'destroy' => 'destroy',
					'contacts_management' => 'contact_management',
					'add_contacts' => 'contacts_management',
					'add_new_user' => 'edit'
				},
		:skip_logging_actions => [])

	# Method implementing the CRUD methods for tht controller (see MakeResourceful plugin for more)
  make_resourceful do
    actions :all, :except => [:index]

    before :show do
      params[:id] ||= params[:workspace_id]
			# Just for the first load of the show, means without item selected
      params[:item_type] ||= get_allowed_item_types(@current_object).first.to_s.pluralize
			params[:w] = [current_workspace.id]
			if !params[:item_type].blank?
				@paginated_objects = params[:item_type].classify.constantize.get_da_objects_list(setting_searching_params(:from_params => params))
			end
    end

		before :new do
			@roles = Role.of_type('workspace')
		end

		before :edit do
			@roles = Role.of_type('workspace')
		end

    before :create do
			params[:id] ||= params[:workspace_id]
      @current_object.creator = @current_user
    end
		after :create do
			UsersWorkspace.create(:user_id => @current_user.id, :workspace_id => @current_object.id, :role_id => Role.find_by_name('ws_admin').id)
			flash[:notice] =I18n.t('workspace.new.flash_notice')
		end
    after :create_fails do
			@roles = Role.of_type('workspace')
      flash.now[:error] =I18n.t('workspace.new.flash_error')
    end

		before :update do
      # Hack. Permit deletion of all assigned users (with roles).
      #params["workspace"]["existing_user_attributes"] ||= {}
    end
		after :update do
      flash[:notice] =I18n.t('workspace.edit.flash_notice')
		end
    after :update_fails do
			@roles = Role.of_type('workspace')
      flash.now[:error] =I18n.t('workspace.edit.flash_error')
    end

		response_for :destroy do |format|
			format.html { redirect_to admin_workspaces_path }
		end
    
		response_for :show do |format|
			format.html { render :action => "show" }
			format.xml { render :xml => @current_object }
			format.json { render :json => @current_object }
			format.atom { render :template => "admin/items/index.atom.builder", :layout => false }
		end
		
	end

	# Action managing the workspaces list (used also with AJAX call, for pagination or ordering)
	#
	# Usage URL :
	# - GET /workspaces
	# - GET /workspaces?by=title-asc&page=2
	def index
		current_objects
		if !request.xhr?
			@no_div = false
			respond_to do |format|
				format.html {   }
				format.xml { render :xml => @paginated_objects }
				format.json { render :json => @paginated_objects }
        format.atom {render :template => "admin/workspaces/index.atom.builder", :layout => false }
			end
		else
			@no_div = true
			render :partial => 'index', :layout => false
		end
	end

  # Method getting the workspace instance depending of the params set
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

  # Method getting all the workspaces depending of user permission
	def current_objects
    params_hash = setting_searching_params(:from_params => params)
    params_hash.merge!({:skip_pag => true}) if params[:format] && params[:format] != 'html'
		@current_objects ||= @paginated_objects = params[:controller].split('/')[1].classify.constantize.get_da_objects_list(params_hash)
	  #Workspace.allowed_user_with_permission(@current_user, 'workspace_show')
	end

  # Action to insert user field with role to the workspace (used with AJAX call)
  #
	# This action is just updating the form, not saving the entry.
	#
  # Usage URL :
  # POST /workspaces/add_new_user
  def add_new_user
		@current_object ||= Workspace.find(params[:id])
    @user = User.find(:first, :conditions => { :login => params[:user_login].split(' (').first })
    @uw = UsersWorkspace.new(:role_id => params[:user_role].to_i, :user_id => @user.id)
    render :update do |page|
      if @user
        page.insert_html :bottom, 'users', :partial => 'user',  :object => @uw
      else
        page.call "alert","No user exist with #{params[:user_login]}"
      end
    end
  end

  # Action to leave the worksapce
	#
	# This action remove the entry linking the current workspace with the current user,
	# from UsersWorkspaces table
  #
  # Usage URL :
  # /workspaces/:id/unsubscription
	def unsubscription
		@current_object = Workspace.find(params[:id])
		if UsersWorkspace.find(:first, :conditions => { :user_id => self.current_user.id, :workspace_id => params[:id] }).destroy
			flash[:notice] = I18n.t('workspace.unsubscription.flash_notice')
			redirect_to admin_workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.unsubscription.flash_error')
			redirect_to admin_workspace_path(params[:id])
		end
	end

  # Action to join a workspace
  #
  # Usage URL :
  # GET /workspaces/:id/subscription
	def subscription
		@current_object = Workspace.find(params[:id])
		if UsersWorkspace.create(:user_id => self.current_user.id, :workspace_id => params[:id], :role_id => Role.find_by_name('reader').id)
			flash[:notice] = I18n.t('workspace.subscription.flash_notice')
			redirect_to admin_workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.subscription.flash_error')
			redirect_to admin_workspace_path(params[:id])
		end
	end

	# Action to send a request to the workspace administrator
	#
	# Usage URL :
	# - POST /workspaces/:id/question
	def question #:nodoc:
		@current_object = Workspace.find(params[:id])
		if UserMailer.deliver_ws_administrator_request(Workspace.find(params[:id]).creator, @current_user.id, params[:question][:type], params[:question][:msg])
			flash[:notice] = I18n.t('workspace.question.flash_notice')
			redirect_to admin_workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.question.flash_error')
			redirect_to admin_workspace_path(params[:id])
		end
	end

end

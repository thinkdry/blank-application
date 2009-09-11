class WorkspacesController < ApplicationController
	
  acts_as_ajax_validation

	acts_as_authorizable({
					'new' => 'new',
					'create' => 'new',
					'edit' => 'edit',
					'update' => 'edit',
					'show' => 'show',
					'rate' => 'rate',
					'add_comment' => 'comment',
					'destroy' => 'destroy',
					'validate' => 'edit',
					'contacts_management' => 'contact_management',
					'add_contacts' => 'contacts_management',
					'add_new_user' => 'edit'
				}, [])

  make_resourceful do
    actions :show, :create, :new, :edit, :update, :destroy, :index

    before :show do
      params[:id] ||= params[:workspace_id]
			# Just for the first load of the show, means without item selected
      params[:item_type] ||= get_allowed_item_types(@current_object).first.to_s.pluralize
      #			@current_objects = get_items_list(params[:item_type], @current_object)
      #			@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
      #<!-- new code
			@paginated_objects = params[:item_type].classify.constantize.get_da_objects_list(build_hash_from_params(params))
      # -->
    end

		before :new do
			@roles = Role.find(:all, :conditions => { :type_role => 'workspace' })
		end

		before :edit do
			@roles = Role.find(:all, :conditions => { :type_role => 'workspace' })
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
			@roles = Role.find(:all, :conditions => { :type_role => 'system' })
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
			@roles = Role.find(:all, :conditions => { :type_role => 'system' })
      flash.now[:error] =I18n.t('workspace.edit.flash_error')
    end

		before :destroy do
		end

		response_for :destroy do |format|
			format.html { redirect_to administration_user_url(@current_user.id) }
		end
    
    #		response_for :show do |format|
    #      format.html { render :action => "show" }
    #      format.xml { render :xml => @current_object }
    #      format.json { render :json => @current_object }
    #      format.atom { render :template => "items/index.atom.builder", :layout => false }
    #    end
	end

  # Set Worksapce if the Worksapce Parameter Exists
	def current_object #:nodoc:
    @current_object ||= @workspace =
      if params[:id]
      Workspace.find(params[:id])
    elsif params[:workspace_id]
      Workspace.find(params[:workspace_id])
    else
      nil
    end
  end

  # Return all Workspaces with allowed permissions
	def current_objects #:nodoc:
		@current_objects ||= @workspaces = Workspace.allowed_user_with_permission(@current_user.id, 'workspace_show')
	end

  # Assign Users with role to Workspace in UsersWorkspace
  #
  # Usage URL
  #
  # /workspaces/add_new_user
  def add_new_user
		@current_object ||= Workspace.find(params[:id])
    @user = User.find(:first, :conditions => { :login => params[:user_login].split(' (').first })
    @uw = UsersWorkspace.new
    @uw.role_id = params[:user_role]
    @uw.user = @user
    render :update do |page|
      if @user
        page.insert_html :bottom, 'users', :partial => 'user',  :object => @uw
      else
        page.call "alert","No user exist with #{params[:user_login]}"
      end
    end
  end

  # Unsubscribe from Worksapce
  #
  # Usage URL
  #
  # /workspaces/unsubscription
  #
	def unsubscription
		@current_object = Workspace.find(params[:id])
		if UsersWorkspace.find(:first, :conditions => { :user_id => self.current_user.id, :workspace_id => params[:id] }).destroy
			flash[:notice] = I18n.t('workspace.unsubscription.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.unsubscription.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

  # Subscribe to Worksapce
  #
  # Usage URL
  #
  # /workspaces/subscription
  #
	def subscription
		@current_object = Workspace.find(params[:id])
		if UsersWorkspace.create(:user_id => self.current_user.id, :workspace_id => params[:id], :role_id => Role.find_by_name('reader').id)
			flash[:notice] = I18n.t('workspace.subscription.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.subscription.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	def question #:nodoc:
		@current_object = Workspace.find(params[:id])
		if UserMailer.deliver_ws_administrator_request(Workspace.find(params[:id]).creator, @current_user.id, params[:question][:type], params[:question][:msg])
			flash[:notice] = I18n.t('workspace.question.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.question.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

end
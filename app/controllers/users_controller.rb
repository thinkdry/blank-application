class UsersController < ApplicationController
	
  acts_as_ajax_validation

	skip_before_filter :is_logged?, :only => [:new, :create, :validate, :forgot_password, :reset_password]

	#layout 'application', :expect => [:new, :create]
	layout :give_da_layout

	def give_da_layout
		if params[:action]== 'new' || params[:action]== 'forgot_password' || params[:action] == 'reset_password'
			if logged_in?
				return 'application'
			else
				return 'login'
			end
		else
			return 'application'
		end
	end

  make_resourceful do
    actions :all

    before :destroy do
      no_permission_redirection unless @current_object.accepts_destroy_for?(@current_user)
    end

    before :edit, :update do
      no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
    end

    before :new, :create do
			if logged_in?
				@search ||= Search.new
				no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
			elsif is_allowed_free_user_creation?
				
			else
				no_permission_redirection
			end
    end

    before :show do
			no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
    end

		before :index do
			# TODO : check in the controller
			no_permission_redirection unless @current_user.has_system_role('superadmin')
			@current_objects = current_objects.paginate(
					:page => params[:page],
					:order => :title,
					:per_page => get_per_page_value
			)
    end

		before :edit do
			if (@current_user.has_system_role('superadmin') || @current_user.has_system_role('admin'))
				@roles = Role.find(:all, :conditions => { :type_role => 'system' })
			else
				@roles = [Role.find_by_name('user')]
			end
		end

		after :create do
			# System role by default, secure assignement
			@current_object.system_role_id = Role.find_by_name('user')
			@current_object.save
			if is_given_private_workspace
				# Creation of the private workspace for the user
				ws = Workspace.create(:title => "Private space of #{@current_object.login}", :creator_id => @current_object.id, :state => 'private')
				# To assign the 'ws_admin' role to the user in his privte workspace
				UserWorkspace.create(:user_id => @current_object.id, :worskpace_id => ws.id, :role_id => Role.find_by_name('ws_admin'))
			end
			flash[:notice] = I18n.t('user.new.flash_notice')
		end

		response_for :create do |format|
			format.html { redirect_to((@current_user ? users_path : '/')) }
		end

		after :create_fails do
			flash[:error] = I18n.t('user.new.flash_error')
    end

		response_for :create_fails do |format|
			format.html { render :action => 'new', :layout => (@current_user ? 'application' : 'login') }
		end

    after :update do
			# System role secure check on Update
			if (@current_user.has_system_role('superadmin') || @current_user.has_system_role('admin'))
				@current_object.system_role_id = params[:user][:system_role_id].to_i
			else
				@current_object.system_role_id = Role.find_by_name('user')
			end
			@current_object.save
			flash[:notice] = I18n.t('user.edit.flash_notice')
    end

    after :update_fails do
			if (@current_user.has_system_role('superadmin') || @current_user.has_system_role('admin'))
				@roles = Role.find(:all, :conditions => { :type_role => 'system' })
			else
				@roles = [Role.find_by_name('user')]
			end
			flash[:error] = I18n.t('user.edit.flash_error')
    end

  end
 
	def autocomplete_on
		conditions = if params['login']
       ["login LIKE :login OR firstname LIKE :login OR lastname LIKE :login",
         { :login => "%#{params['login']}%"}]
     else
       {}
     end
     @objects ||= User.find(:all, :conditions => conditions)
		 render :text => '<ul>'+@objects.map{ |e| "<li>#{e.login} (#{e.full_name})</li>" }.join(' ')+'</ul>'
	end
	
	# Function allowing to activate the user with the RESTful authentification plugin
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Subscription complete !"
    end
    redirect_back_or_default('/')
  end

	# Function allowing to gain his password by email in case of forgot
  def forgot_password    
		return unless request.post?
		if @user = User.find_by_email(params[:user][:email])
		  @user.create_reset_code
		  flash.now[:notice_forgot] = I18n.t('user.forgot_password.flash_notice')
			render :action => "forgot_password"
		else
		  flash.now[:error_forgot] = I18n.t('user.forgot_password.flash_error')
			render :action => "forgot_password"
		end
  end
 
  # Function allowing to reset the password of the current user after to have received a reset link in an email
  def reset_password
    if (@user = User.find_by_password_reset_code(params[:password_reset_code]) unless params[:password_reset_code].nil?)
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "#{@user.login},"+I18n.t('user.reset_password.flash_notice')
        redirect_to "/login"
      else
				flash[:error] = I18n.t('user.reset_password.flash_error')
        render :action => :reset_password
      end
		end
    else
			flash[:error] = I18n.t('user.reset_password.flash_error_link')
			redirect_to "/login"
		end
  end

	# Overwritting the AjaxValidation plugin to manage the permission
	def validate
    model_class = params['model'].classify.constantize
    @model_instance = params['id'] ? model_class.find(params['id']) : model_class.new
    @model_instance.send("#{params['attribute']}=", params['value'])
    @model_instance.valid?
    render :inline => "<%= error_message_on(@model_instance, params['attribute']) %>"
  end

	# permit 'administration of user'
	def administration
		@current_object = current_user
		@workspaces = if (current_user.has_system_permission('workspace', 'show'))
		  Workspace.find(:all)
	  else
	    Workspace.allowed_user_with_permission(@current_user.id, 'workspace_show')
    end
  end
 
end

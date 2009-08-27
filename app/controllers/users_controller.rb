class UsersController < ApplicationController
	
  acts_as_ajax_validation

	skip_before_filter :is_logged?, :only => [:new, :create, :validate, :forgot_password, :reset_password, :activate]

	before_filter :permission_checking, :only => [:new, :create, :edit, :update, :show, :destroy]

	def permission_checking
		if params[:action] == 'new' || params[:action] == 'create'
			build_object
			no_permission_redirection unless (@current_user.nil? && is_allowed_free_user_creation?) || (@current_user && @current_object.send("accepts_new_for?".to_sym, @current_user))
		elsif params[:action] == 'edit' || params[:action] == 'update'
			current_object
			no_permission_redirection unless @current_user && @current_object.send("accepts_edit_for?".to_sym, @current_user)
		else
			current_object
			no_permission_redirection unless @current_user && @current_object.send("accepts_#{params[:action]}_for?".to_sym, @current_user)
		end
	end

	#layout 'application', :expect => [:new, :create]
	layout :give_da_layout

  # Check Current User Status and Give the Layout
	def give_da_layout 
		if params[:action]== 'new' || params[:action]== 'forgot_password' || params[:action] == 'reset_password'
			if logged_in?
				return get_da_layout
			else
				return 'login'
			end
		else
			return get_da_layout
		end
	end

  make_resourceful do
    actions :all, :except => [:create]

    before :new do
			if logged_in?
				@search ||= Search.new
        get_roles
			elsif is_allowed_free_user_creation?
				if @current_object.id # captcha just on create
					render :action => 'new', :layout => 'login' unless yacaph_validated?
        end
			else
				no_permission_redirection
			end
    end

		before :edit do
			get_roles
		end

    #		after :create do
    #			# System role by default, secure assignement
    #			@current_object.system_role_id = Role.find(:first, :conditions => {:name => 'user'}).id
    #			@current_object.save
    #			#raise "iamthere"
    #			if is_given_private_workspace
    #				@current_object.create_private_workspace
    #			end
    #			flash[:notice] = I18n.t('user.new.flash_notice')
    #		end
    #
    #		response_for :create do |format|
    #			format.html { redirect_to((@current_user ? users_path : '/')) }
    #		end
    #
    #		after :create_fails do
    #			flash[:error] = I18n.t('user.new.flash_error')
    #    end
    #
    #		response_for :create_fails do |format|
    #			format.html { render :action => 'new', :layout => (@current_user ? get_da_layout : 'login') }
    #		end

    after :update do
			# System role secure check on Update
			get_roles
			@current_object.save
      #			if is_given_private_workspace && !Workspace.exists?(:creator_id => @current_object.id, :state => 'private')
      #				@current_object.create_private_workspace
      #			end
			flash.now[:notice] = I18n.t('user.edit.flash_notice')
    end

    after :update_fails do
			get_roles
			flash.now[:error] = I18n.t('user.edit.flash_error')
    end

  end

	def locking
		current_object
		if @current_object.activation_code == 'unlocked'
			if @current_object.lock
				flash[:notice] = I18n.t('user.locking.lock_flash_notice')
			else
				flash[:error] = I18n.t('user.locking.flash_error')
			end
		else
			if @current_object.unlock
				flash[:notice] = I18n.t('user.locking.unlock_flash_notice')
			else
				flash[:error] = I18n.t('user.locking.flash_error')
			end
		end
		redirect_to '/users'
	end

  # Create New User /users/new
  def create #:nodoc:
    # System role by default, secure assignement
    @current_object = User.new(params[:user])
    valid_user = false
    if current_user
      valid_user = @current_object.save
    else
      @current_object.system_role_id = Role.find_by_name('user').id
      if yacaph_validated?
        if @current_object.save
          valid_user = true
        end
      else
        @captcha_valid = false
      end
    end
    if valid_user
      if is_given_private_workspace
        @current_object.create_private_workspace
      end
      flash[:notice] = I18n.t('user.new.flash_notice')
      respond_to do |format|
        format.html { redirect_to('/') }
      end
    else
      if logged_in?
        get_roles
        @search ||= Search.new
      end
      flash.now[:error] = I18n.t('user.new.flash_error')
      respond_to do |format|
        format.html { render :action => 'new', :layout => (current_user ? get_da_layout : 'login') }
      end
    end
  end

  # Ajax Users Index with User
  def ajax_index
    current_objects
    render :partial => 'user_in_list'
  end

  # Users Index Object for All Users
	def current_objects #:nodoc:
    params[:page] ||= 1
		if @current_user.has_system_role('superadmin')
      @current_objects = User.paginate(:per_page => get_per_page_value, :page => params[:page])
		elsif @current_user.has_system_role('admin')
			@current_objects = User.paginate_by_sql("SELECT users.* FROM users, roles WHERE users.system_role_id=roles.id AND roles.name!='superadmin' AND users.activation_code!='locked'", :per_page => get_per_page_value, :page => params[:page])
		else
      @current_objects = User.paginate_by_sql("SELECT users.* FROM users INNER JOIN users_workspaces ON users.id = users_workspaces.user_id WHERE ((users_workspaces.workspace_id IN (SELECT workspaces.id FROM workspaces LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{@current_user.id} LEFT JOIN permissions_roles ON permissions_roles.role_id = users_workspaces.role_id LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id WHERE (permissions.name = 'user_show')))) AND users.activated_at IS NOT NULL GROUP BY users.id ORDER BY users.login", :per_page => get_per_page_value, :page => params[:page])
		end
	end

  # AutoComplete for Users in TextBox
  #
  # Usage URL
  #
  # /users/autocomplete_on
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
  #
  # Usage URL
  #
  # /users/activate
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Subscription complete !"
    end
    redirect_back_or_default('/')
  end

  # Function allowing to gain his password by email in case of forgot
  #
  # Usage URL
  #
  # /forgot_password
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
  #
  # Usage URL
  #
  # /reset_password
  def reset_password
    if (@user = User.find_by_password_reset_code(params[:password_reset_code]) unless params[:password_reset_code].nil?)
      if request.post?
        if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
          self.current_user = @user
          @user.delete_reset_code
          flash[:notice] = "#{@user.login},"+I18n.t('user.reset_password.flash_notice')
          redirect_to "/login"
        else
          flash.now[:error] = I18n.t('user.reset_password.flash_error')
          render :action => :reset_password
        end
      end
    else
      flash[:error] = I18n.t('user.reset_password.flash_error_link')
      redirect_to "/login"
    end
  end

  # Overwritting the AjaxValidation plugin to manage the permission
  #
  # /users/validate
  def validate
    model_class = params['model'].classify.constantize
    @model_instance = params['id'] ? model_class.find(params['id']) : model_class.new
    @model_instance.send("#{params['attribute']}=", params['value'])
    @model_instance.valid?
    render :inline => "<%= error_message_on(@model_instance, params['attribute']) %>"
  end

  # TODO remove it, just direct links in the old layout, to hell ajax my zob

  # Administration of Workspaces for User
   #
  # Usage URL
  #
  # /users/administration
  def administration
    @current_object = current_user
    @workspaces = if (current_user.has_system_permission('workspace', 'show'))
      Workspace.find(:all)
    else
      Workspace.allowed_user_with_permission(@current_user.id, 'workspace_show')
    end
  end

  # allow only post pethod to resend activation mail again or activate manually by admin only and parameter id is user's activation_code
  def resend_activation_mail_or_activate_manually
    if @current_user.has_system_role('admin') and @user = User.find_by_activation_code(params[:id])
      UserMailer.deliver_signup_notification(@user) if !params[:resend_activation_mail].nil?
      @user.activate if !params[:activate_manually].nil?
      redirect_to users_path
    else
      flash[:error] = I18n.t('general.common_message.permission_denied')
      redirect_to '/'
    end
  end

  private
  def get_roles
    if (@current_user.has_system_role('superadmin') || @current_user.has_system_role('admin'))
      @roles = Role.find(:all, :conditions => { :type_role => 'system' })
    else
      @roles = [Role.find_by_name('user')]
    end
  end

end

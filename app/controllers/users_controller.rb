class UsersController < ApplicationController
  acts_as_ajax_validation
	
	skip_before_filter :is_logged?, :only => [:forgot_password, :reset_password, :activate]

	before_filter user_can_access('user', 'new'), :only => [:new, :create]
	before_filter user_can_access('user', 'edit', (params[:id]=@current_user.id), false, false), :only => [:edit, :update]
	before_filter user_can_access('user', 'destroy', (params[:id]=@current_user.id), false, false)), :only => [:destroy]
	before_filter user_can_access('user', 'show', (params[:id]=@current_user.id), false, false), :only => [:show, :index]

	layout "application", :except => [:forgot_password, :reset_password]

  make_resourceful do
    actions :all
    
#    before :destroy do
#      permit "deletion of user"
#    end
#
#    before :edit, :update do
#      permit "edition of user"
#    end
#
#
#    before :new, :create do
#      permit "creation of user"
#    end
    
    before :show do
      @is_admin = @current_object.is_admin?
      @moderated_ws =
        Workspace.with_moderator_role_for(@current_object) |
        Workspace.administrated_by(@current_object)
      @writter_role_on_ws = Workspace.with_writter_role_for(@current_object)
      @reader_role_on_ws = Workspace.with_reader_role_for(@current_object)
    end
		
		before :index do
			@current_objects = current_objects.paginate(
     	:page => params[:page],
			:order => :title,
			:per_page => 20
		)
    end

		after :create do
			# Creation of the private workspace fur the user
			Workspace.create(:title => "Private space of #{@current_object.login}", :creator_id => @current_object.id, :state => 'private')
		end
		
    response_for :index do |format|
      format.html { render :layout => false }
    end
  end
 
  def current_objects
     conditions = if params['login']
       ["login LIKE :login OR firstname LIKE :login OR lastname LIKE :login", 
         { :login => "%#{params['login']}%"}]
     else
       {}
     end
     @current_objects ||= current_model.find(:all, :conditions => conditions)
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
		  flash.now[:notice_forgot] = "A link that allows you to change your password has been send by e-mail."
			render :action => "forgot_password"
		else
		  flash.now[:error_forgot] = "There is no user with this e-mail address."
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
        flash[:notice] = "#{@user.login}, Your password has been successfully changed"
        redirect_to "/login"
      else
				flash[:error] = "Your password has not been changed."
        render :action => :reset_password
      end
		end
    else
			flash[:error] = "This link is no more valid."
			redirect_to "/login"
		end
  end  
	
	def administration
		@current_object = current_user
		@workspace = Workspace.new
		@workspaces = if (current_user.system_role == "Admin")
		  Workspace.find(:all)
	  else
	    Workspace.administrated_by(current_user) + Workspace.moderated_by(current_user)
    end
  end
 
end

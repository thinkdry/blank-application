class UsersController < ApplicationController
  acts_as_ajax_validation
	
	skip_before_filter :is_logged?, :only => [:forgot_password, :reset_password]
	layout "application", :except => [:forgot_password, :reset_password]

  make_resourceful do
    actions :all
		belongs_to :account
    
    before :remove do
      permit "deletion of user"
    end
    
    before :edit, :update do
      permit "edition of user"
    end
    
    before :new, :create do
      permit "creation of user"
    end
    
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
	 
	# Function allowing to gain his password by email in case of forgot
  def forgot_password    
		return unless request.post?
		if @user = User.find_by_email(params[:user][:email])
		  @user.create_reset_code
		  flash[:notice] = "Un lien permettant le changement de votre mot de passe vous a été envoyé sur votre messagerie." 
			render :action => "forgot_password"
		else
		  flash[:error] = "Aucun utilisateur ne correspond à cette adresse email." 
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
        flash[:notice] = "Mot de passe changé avec succès pour #{@user.login}"
        redirect_to "/login"
      else
				flash[:error] = "Le mot de passe n'a pu être changé."
        render :action => :reset_password
      end
		end
    else
			flash[:error] = "Ce lien n'est plus valide."
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
	
	def superadministration
		@current_object = current_user	
		if params[:part] == "default" 
			
    end
		if params[:part] == "pictures"
			@logo = Picture.find_by_name('logo')
			render :partial => 'users/superadministration/pictures'
    end
		if params[:part] == "colors"
                       
                        @elements = Element.find(:all,:conditions=>{:template=>"current"})
                        @temp=Element.find( :all,:select => 'DISTINCT template' )
                        
			render :partial => 'users/superadministration/colors'
               end
		if params[:part] == "fonts"
			render :partial => 'users/superadministration/fonts'
    end
		if params[:part] == "languages"
			#render :partial => 'users/superadministration/'
    end
  end
	
	def picture_changing
		if current_user.is_superadmin?
			@picture = Picture.new(params[:picture])
			if Picture.find_by_name('logo')
				Picture.find_by_name('logo').update_attributes(:name => 'old_logo')
                         end
			if @picture.save
				redirect_to user_superadministration_url(current_user.id)
				flash[:notice] = "Logo mis à jour"
			else
				render :nothing =>:true
			end
		else
			redirect_to "/"
			flash[:notice] = "Vous n'avez pas ce droit."
		end
	end
  
end

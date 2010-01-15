class Superadmin::RolesController < Admin::ApplicationController

  # Filter restricting the ressource access to only superadministrator user
	before_filter :is_superadmin?

  before_filter :get_role, :only => [:edit, :update, :destroy]

	# Mixin method implementing ajax validation for that controller
  acts_as_ajax_validation

	# Action managing roles list
	#
	# Usage URL :
  # - GET /roles
  # - GET /roles.xml
  def index
    @system_roles = Role.of_type('system').delete_if{|a| a.name == 'superadmin'}
		@workspace_roles = Role.of_type('container')
		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => @roles }
		end
  end

  #	# Action managing the role show
  #	#
  #	# Usage URL :
  #	# - GET /roles/1
  #  # - GET /roles/1.xml
  #	def show
  #		@role = Role.find(params[:id])
  #
  #		respond_to do |format|
  #			format.html # show.html.erb
  #			format.xml  { render :xml => @role }
  #		end
  #	end

	# Action managing the new form
	#
	# Usage URL :
	# - GET /roles/new
	# - GET /roles/new.xml
  def new
    @role = Role.new
		@role.type_role = params[:type_role]
		get_permissions
		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @role }
		end
  end

	# Action managing the edit form
	#
	# Usage URL :
	# - GET /roles/1/edit
  def edit
		get_permissions
    respond_to do |format|
			format.html # edit.html.erb
			format.xml  { render :xml => @role }
		end
  end

	# Action managing the role creation
	#
	# Usage URL :
  # - POST /roles
  # - POST /roles.xml
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
			if @role.save
			  params[:permissions] ||= []
        @role.set_permissions(params[:permissions])
				flash[:notice] = 'Role was successfully created.'
				format.html { redirect_to(superadmin_roles_path) }
				format.xml  { render :xml => @role, :status => :created, :location => superadmin_role_path(@role) }
			else
				flash.now[:error] = 'Role Creation Failed.'
				get_permissions
				format.html { render :action => "new" }
				format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
			end
    end
  end

	# Action managing the role update
	#
	# Usage URL :
	# - PUT /roles/1
	# - PUT /roles/1.xml
  def update
    respond_to do |format|
			if @role.update_attributes(params[:role])
			  params[:permissions] ||= []
        @role.set_permissions(params[:permissions])
				flash[:notice] = 'Role was successfully updated.'
				format.html { redirect_to(superadmin_roles_path) }
				format.xml  { head :ok }
			else
        flash.now[:error] = 'Role update failed.'
				get_permissions
				format.html { render :action => "edit" }
				format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
			end
    end
  end

	# Action managing role deletion
	#
	# Usage URL :
	# - DELETE /roles/1
	# - DELETE /roles/1.xml
  def destroy
    if @role.name == 'superadmin'
      flash[:error] = "SuperAdministrator Cannot Be Deleted!"
      respond_to do |format|
        format.html { redirect_to(superadmin_roles_path) }
        format.xml  { head :ok }
      end
    else
      @role.destroy
      respond_to do |format|
        format.html { redirect_to(superadmin_roles_path) }
        format.xml  { head :ok }
      end
    end
  end

	private

  def get_role
    @role = Role.find(params[:id])
  end
  # Method allowing to get the permissions lists regarding the role type (workspace or system)
  def get_permissions
    if @role.type_role=="system"
			@permissions = Permission.find(:all, :order => 'name ASC')
	  else
      @permissions = Permission.type_of(@role.type_role)
    end
  end
end

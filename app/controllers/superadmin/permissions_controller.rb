class Superadmin::PermissionsController < Admin::ApplicationController

	# Filter restricting the ressource access to only superadministrator user
	before_filter :is_superadmin?

  before_filter :get_permission, :only => [:edit, :update, :destroy]

	# Mixin method implementing ajax validation for that controller
  acts_as_ajax_validation
  
	# Action managing permissions list
	#
	# Usage URL :
	# - GET /permissions
	# - GET /permissions.xml
  def index
    @permissions = Permission.find(:all)
		respond_to do |format|
			format.html
			format.xml  { render :xml => @permissions }
		end
  end

#	# Action managing the permission show
#	#
#	# Usage URL :
#	# - GET /permissions/1
#  # - GET /permissions/1.xml
#	def show
#		@permission = Permission.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml  { render :xml => @permission }
#		end
#	end


	# Action managing the new form
	#
	# Usage URL :
	# - GET /permissions/new
	# - GET /permissions/new.xml
  def new
    @permission = Permission.new
		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @permission }
		end
  end

	# Action managing the edit form
	#
	# Usage URL :
	# - GET /permissions/1/edit
  def edit
		respond_to do |format|
			format.html # edit.html.erb
			format.xml  { render :xml => @permission }
		end
  end

	# Action managing the permission creation
	#
	# Usage URL :
	# - POST /permissions
	# - POST /permissions.xml
  def create
    @permission = Permission.new(params[:permission])
    respond_to do |format|
			if @permission.save
				flash.now[:notice] = 'Permission was successfully created.'
				format.html { redirect_to(superadmin_permissions_path) }
				format.xml  { render :xml => @permission, :status => :created, :location => superadmin_permission_path(@permission) }
				@permissions= Permission.find(:all)
			else
        flash.now[:error] = 'Permission Updation Failed.'
				format.html { render :action => "new" }
				format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
			end
    end
  end

	# Action managing the permission update
	#
	# Usage URL :
	# - PUT /permissions/1
	# - PUT /permissions/1.xml
  def update
    respond_to do |format|
			if @permission.update_attributes(params[:permission])
				flash.now[:notice] = 'Permission was successfully updated.'
				format.html { redirect_to(superadmin_permissions_path) }
				format.xml  { head :ok }
			else
				flash.now[:error] = 'Permission Updation Failed.'
				format.html { render :action => "edit" }
				format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
			end
    end
  end

	# Action allowing permission deletion
	#
	# Usage URL :
	# - DELETE /permissions/1
	# - DELETE /permissions/1.xml
  def destroy
    @permission.destroy
    @permissions= Permission.find(:all)
		respond_to do |format|
			format.html { redirect_to(superadmin_permissions_url) }
			format.xml  { head :ok }
		end
  end

  private

  def get_permission
    @permission = Permission.find(params[:id])
  end

end

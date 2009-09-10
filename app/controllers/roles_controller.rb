class RolesController < ApplicationController #:nodoc: all

  acts_as_ajax_validation

	# Filter to just allow 'superadmin' user to access to that resource
	before_filter :is_superadmin?

  # GET /roles
  # GET /roles.xml
  def index
    @system_roles = Role.find(:all, :conditions => { :type_role => 'system'} )
		@workspace_roles = Role.find(:all, :conditions => { :type_role => 'workspace'} )
        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @roles }
        end
  end

  # GET /roles/1
  # GET /roles/1.xml
  #  def show
  #    @role = Role.find(params[:id])
  #
  #    respond_to do |format|
  #      format.html # show.html.erb
  #      format.xml  { render :xml => @role }
  #    end
  #  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new
		@role.type_role = params[:type_role]
		get_permissions
        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @role }
        end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
		get_permissions
    respond_to do |format|
          format.html # edit.html.erb
          format.xml  { render :xml => @role }
        end
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
    if @role.save
			if params[:permissions]
				params[:permissions].each do |k, v|
					@role.permissions << Permission.find(k.to_i)
				end
			end
      flash[:notice] = 'Role was successfully created.'
              format.html { redirect_to(roles_path) }
              format.xml  { render :xml => @role, :status => :created, :location => role_path(@role) }
    else
      flash.now[:error] = 'Role Creation Failed.'
      get_permissions
              format.html { render :action => "new" }
              format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
    end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    respond_to do |format|
			if @role.update_attributes(params[:role])
				@role.permissions.delete_all
				if params[:permissions]
					params[:permissions].each do |k, v|
						@role.permissions << Permission.find(k.to_i)
					end
				end
				@role.save
				flash[:notice] = 'Role was successfully updated.'
								format.html { redirect_to(roles_path) }
								format.xml  { head :ok }
			else
        flash.now[:error] = 'Role update failed.'
                get_permissions
								format.html { render :action => "edit" }
								format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
			end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    if @role.name == 'superadmin'
      flash[:error] = "SuperAdministrator Cannot Be Deleted!"
      respond_to do |format|
        format.html { redirect_to(roles_url) }
        format.xml  { head :ok }
      end
    else
      @role.destroy
      respond_to do |format|
        format.html { redirect_to(roles_url) }
        format.xml  { head :ok }
      end
    end

  end
    
  #
  def get_permissions
    if @role.type_role=="system"
			@permissions = Permission.find(:all, :order => 'name ASC')
		else
			#@permissions = Permission.find(:all)
			@permissions = Permission.find(:all, :conditions => { :type_permission => 'workspace' }, :order => 'name ASC')
		end
  end
end

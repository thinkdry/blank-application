class RolesController < ApplicationController #:nodoc: all

	# Filter to just allow 'superadmin' user to access to that resource
	before_filter :is_superadmin?

  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.find(:all)
    render :partial => "index", :object => @roles
    #    respond_to do |format|
    #      format.html # index.html.erb
    #      format.xml  { render :xml => @roles }
    #    end
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
		if params[:type_role]=='system'
			@permissions = Permission.find(:all)
		else
			@permissions = Permission.find(:all, :conditions => { :type_permission => 'workspace' })
		end
    render :partial => "new", :layout => false
    #    respond_to do |format|
    #      format.html # new.html.erb
    #      format.xml  { render :xml => @role }
    #    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find_by_name(params[:role_name])
		if @role.type_role=="system"
			@permissions = Permission.find(:all)
		else
			#@permissions = Permission.find(:all)
			@permissions = Permission.find(:all, :conditions => { :type_permission => 'workspace' })
		end
    render :partial => "edit"
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])
    #respond_to do |format|
    if @role.save
			if params[:permissions]
				params[:permissions].each do |k, v|
					@role.permissions << Permission.find(k.to_i)
				end
			end
      flash[:notice] = 'Role was successfully created.'
      #        format.html { redirect_to(role_path(@role)) }
      #        format.xml  { render :xml => @role, :status => :created, :location => role_path(@role) }
    else
      flash[:notice] = 'Role Creation Failed.'
      #        format.html { render :action => "new" }
      #        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
    end
    #end
    redirect_to '/superadministration/rights'
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    #respond_to do |format|
    if @role.update_attributes(params[:role])
			@role.permissions.delete_all
			if params[:permissions]
				params[:permissions].each do |k, v|
					@role.permissions << Permission.find(k.to_i)
				end
			end
			@role.save
      flash[:notice] = 'Role was successfully updated.'
      #        format.html { redirect_to(role_path(@role)) }
      #        format.xml  { head :ok }
    else
      #        format.html { render :action => "edit" }
      #        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
    end
    #end
    redirect_to '/superadministration/rights'
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    if @role.name == 'superadmin'
      flash[:notice] = "SuperAdministrator Cannot Be Deleted!"
      redirect_to '/superadministration/rights'
    else
      @role.destroy
      redirect_to '/superadministration/rights'
    end

  end
    
  #    respond_to do |format|
  #      format.html { redirect_to(roles_url) }
  #      format.xml  { head :ok }
  #    end
end

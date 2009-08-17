class PermissionsController < ApplicationController #:nodoc: all

	# Filter to just allow 'superadmin' user to access to that resource
	before_filter :is_superadmin?

  acts_as_ajax_validation
  
  # GET /permissions
  # GET /permissions.xml
  def index
    @permissions = Permission.find(:all)
    render :partial => "index", :object => @permissions
    #    respond_to do |format|
    #      format.html { render :partial => "index"}
    #      format.xml  { render :xml => @permissions }
    #    end
  end

  # GET /permissions/1
  # GET /permissions/1.xml
  #  def show
  #    @permission = Permission.find(params[:id])
  #    render :partial => "show"
  #        respond_to do |format|
  #          format.html # show.html.erb
  #          format.xml  { render :xml => @permission }
  #        end
  #  end

  # GET /permissions/new
  # GET /permissions/new.xml
  def new
    @permission = Permission.new
    render :partial => "new"
    #    respond_to do |format|
    #      format.html # new.html.erb
    #      format.xml  { render :xml => @permission }
    #    end
  end

  # GET /permissions/1/edit
  def edit
    @permission = Permission.find(params[:id])
    render :partial => "edit"
    #    render :update do |page|
    #      page.replace_html  'permissions', :partial => 'index'
    #    end
  end

  # POST /permissions
  # POST /permissions.xml
  def create
    @permission = Permission.new(params[:permission])
    # respond_to do |format|
    if @permission.save
      flash.now[:notice] = 'Permission was successfully created.'
      #format.html { redirect_to(permission_path(@permission)) }
      #format.xml  { render :xml => @permission, :status => :created, :location => permission_path(@permission) }
      @permissions= Permission.find(:all)
      render :update do |page|
        page.replace_html  'roles', :partial => 'index', :object=> @permissions
      end
    else
      render :update do |page|
        page.replace_html  'roles', :partial => 'new'
      end
      #format.html { render :action => "new" }
      #format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
    end
    
    #end
  end

  # PUT /permissions/1
  # PUT /permissions/1.xml
  def update
    @permission = Permission.find(params[:id])
    #respond_to do |format|
    if @permission.update_attributes(params[:permission])
      flash.now[:notice] = 'Permission was successfully updated.'
      #format.html { redirect_to(permission_path(@permission)) }
      #format.xml  { head :ok }
    else
      flash.now[:notice] = 'Permission Updation Failed.'
      #format.html { render :action => "edit" }
      #format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
    end
    @permissions= Permission.find(:all)
    render :update do |page|
      page.replace_html  'roles', :partial => 'index', :object=> @permissions
    end
    #end
  end

  # DELETE /permissions/1
  # DELETE /permissions/1.xml
  def destroy
    @permission = Permission.find(params[:id])
    @permission.destroy
    @permissions= Permission.find(:all)
    render :partial => "index", :object => @permissions
    #    respond_to do |format|
    #      format.html { redirect_to(permissions_url) }
    #      format.xml  { head :ok }
    #    end
  end
end

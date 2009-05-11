class CommentsController < ApplicationController

	unloadable

	#before_filter :is_superadmin?

  # GET /comments
  # GET /comments.xml
  def index
		if params[:on_state] && (params[:on_state] != 'all')
			@current_objects = Comment.find(:all, :order => 'created_at DESC', :conditions => { :state => params[:on_state] }).paginate(:per_page => get_per_page_value, :page => params[:page])
		else
			@current_objects = Comment.find(:all, :order => 'created_at DESC').paginate(:per_page => get_per_page_value, :page => params[:page])
		end
    respond_to do |format|
			format.html
			format.xml { render :xml => @current_objects }
    end
  end

	# GET /comments/new
  def new
    @current_object = Comment.new
		respond_to do |format|
			format.html
			format.xml  { render :xml => @current_object }
    end
  end

  # GET /comments/1/edit
  def edit
    @current_object = Comment.find(params[:id])
		respond_to do |format|
			format.html
			format.xml { render :xml => @current_object }
    end
  end

  # POST /comments
  # POST /comments.xml
  def create
    @current_object = Comment.new(params[:comment])
		respond_to do |format|
			if @current_object.save
				flash[:notice] = 'Comment was successfully created.'
				format.html { redirect_to(comment_path(@current_object)) }
				format.xml  { render :xml => @current_object, :status => :created, :location => comment_path(@current_object) }
			else
				flash[:error] = 'Comment creation failed.'
				format.html { render :action => "new" }
				format.xml  { render :xml => @current_object.errors, :status => :unprocessable_entity }
			end
		end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @current_object = Comment.find(params[:id])
    respond_to do |format|
			if @current_object.update_attributes(params[:comment])
				flash[:notice] = 'Comment was successfully updated.'
				format.html { redirect_to(comments_path) }
				format.xml  { head :ok }
			else
				flash[:error] = 'Comment update failed.'
				format.html { render :action => "edit" }
				format.xml  { render :xml => @current_object.errors, :status => :unprocessable_entity }
			end
		end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @current_object = Comment.find(params[:id])
		respond_to do |format|
			if @current_object.destroy
				@current_objects = Comment.find(:all)
				flash[:notice] = 'Comment was successfully deleted.'
				format.html { redirect_to(comments_url) }
				format.xml  { head :ok }
			else
				@current_objects = Comment.find(:all)
				flash[:error] = 'Comment deletion error.'
				format.html { redirect_to(comments_url) }
				format.xml  { head :ok }
			end
		end
  end

	# Change the state of the comment : posted, validated, rejected
	def change_state
		@current_object = Comment.find(params[:id])
		@current_object.state = params[:new_state]
		@current_object.save
		redirect_to comments_url
	end
	
end

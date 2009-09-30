# This controller manages the actions relation to the Comment object.
class CommentsController < ApplicationController

	unloadable
	# Filters managing the rights on the comment actions
	before_filter :is_superadmin?, :only => ['edit', 'update', 'destroy']
  before_filter :is_admin?, :only => ['edit', 'update', 'destroy']

	# Standart action for list presentation
	#
	# Usage URL :
  # - GET /comments
  # - GET /comments.xml
  def index
#		if params[:on_state] && (params[:on_state] != 'all')
#			@current_objects = Comment.find(:all, :order => 'created_at DESC', :conditions => { :state => params[:on_state], :parent_id => nil }).paginate(:per_page => get_per_page_value, :page => params[:page])
#		else
#			@current_objects = Comment.find(:all, :conditions => {:parent_id => nil}, :order => 'created_at DESC').paginate(:per_page => get_per_page_value, :page => params[:page])
#		end
    conditions = (!params[:on_state].nil? && params[:on_state] != 'all') ? "AND state ='#{params[:on_state]}'" : ''
    if @current_user.has_system_role('superadmin')
      @paginated_objects = Comment.find(:all, :conditions => ["parent_id <=> NULL #{conditions}"], :order => 'created_at DESC').paginate(:per_page => get_per_page_value, :page => params[:page])
    else
      @paginated_objects = Comment.find(:all, :conditions => ["parent_id <=> NULL AND user_id =#{@current_user.id} #{conditions}"], :order => 'created_at DESC').paginate(:per_page => get_per_page_value, :page => params[:page])
    end
    respond_to do |format|
			format.html
#			format.xml { render :xml => @current_objects }
    end
  end

	# Standart action for new form presentation
	#
	# Usage URL :
	# - GET /comments/new
  def new
    @current_object = Comment.new
		respond_to do |format|
			format.html
			format.xml  { render :xml => @current_object }
    end
  end

	# Standart action for edit form presentation
	#
	# Usage URL :
  # - GET /comments/:id/edit
  def edit
    @current_object = Comment.find(params[:id])
		respond_to do |format|
			format.html
			format.xml { render :xml => @current_object }
    end
  end

	# Standart action for object creation
	#
	# Usage URL :
  # - POST /comments
  # - POST /comments.xml
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

	# Standart action for object updation
	#
	# Usage URL :
  # - PUT /comments/1
  # - PUT /comments/1.xml
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

	# Standart action for object deletion
	#
	# Usage URL :
  # - DELETE /comments/1
  # - DELETE /comments/1.xml
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

	# Acction allowing to change the state of the comment : posted, validated, rejected
	def change_state
		@current_object = Comment.find(params[:id])
		@current_object.state = params[:new_state]
		@current_object.save
		redirect_to comments_url
	end

	# Action allowing to reply on a posted comment, with Captcha or not
  def add_reply
    if logged_in?
      @current_object = Comment.create(params[:comment].merge(:user => @current_user, :state => DEFAULT_COMMENT_STATE))
      @current_object.save
      render :update do |page|
        if @current_object.state == 'validated'
          page.insert_html :bottom, "reply_for_comment_#{@current_object.parent_id}", :partial => "comments/reply", :object => @current_object
          page.replace_html "ajax_info", :text => I18n.t('comment.add_comment.ajax_message_comment_published')
        else
          page.replace_html "ajax_info", :text => I18n.t('comment.add_comment.ajax_message_comment_submited')
        end
      end
    else
      if yacaph_validated?
        current_object.comments.create(params[:comment])
        current_object.comments_number = current_object.comments_number.to_i + 1
        current_object.save
        render :update do |page|
          page.replace_html "ajax_info", :text => I18n.t('comment.add_comment.ajax_message_comment_submited')
          page.replace_html "comment_captcha",  :partial => "items/captcha"
        end
      else
        render :update do |page|
          page.replace_html "ajax_info", :text => I18n.t('general.common_word.ajax_message_captcha_invalid')
          page.replace_html "comment_captcha",  :partial => "items/captcha"
        end
      end
    end
  end
	
end

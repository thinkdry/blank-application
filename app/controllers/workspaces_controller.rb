class WorkspacesController < ApplicationController
	
  acts_as_ajax_validation

  make_resourceful do
    actions :show, :create, :new, :edit, :update, :destroy

    before :show do
      no_permission_redirection unless @current_object && @current_object.accepts_show_for?(@current_user)
      params[:id] ||= params[:workspace_id]
			params[:item_type] ||= (@current_object.ws_items.split(',') & @configuration['sa_items']).first.to_s.pluralize
			@current_objects = get_items_list(params[:item_type], @current_object)
			@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
    end

		before :new do
			no_permission_redirection unless @current_object && @current_object.accepts_new_for?(@current_user)
			@roles = Role.find(:all, :conditions => { :type_role => 'workspace' })
		end

		before :edit do
			no_permission_redirection unless @current_object && @current_object.accepts_edit_for?(@current_user)
			@roles = Role.find(:all, :conditions => { :type_role => 'workspace' })
		end

    before :create do
			no_permission_redirection unless @current_object && @current_object.accepts_new_for?(@current_user)
			params[:id] ||= params[:workspace_id]
      @current_object.creator = @current_user
    end
		after :create do
			UsersWorkspace.create(:user_id => @current_user.id, :workspace_id => @current_object.id, :role_id => Role.find_by_name('ws_admin').id)
			flash[:notice] =I18n.t('workspace.new.flash_notice')
		end
    after :create_fails do
			@roles = Role.find(:all, :conditions => { :type_role => 'system' })
      flash[:error] =I18n.t('workspace.new.flash_error')
    end

		before :update do
      no_permission_redirection unless @current_object && @current_object.accepts_edit_for?(@current_user)
      # Hack. Permit deletion of all assigned users (with roles).
      #params["workspace"]["existing_user_attributes"] ||= {}
    end
		after :update do
      flash[:notice] =I18n.t('workspace.edit.flash_notice')
		end
    after :update_fails do
			@roles = Role.find(:all, :conditions => { :type_role => 'system' })
      flash[:error] =I18n.t('workspace.edit.flash_error')
    end
    after :show do
			@current_object.ws_config.update_attributes(:ws_items => check_to_tab(:items).join(","), :ws_feed_items_importation_types => check_to_tab(:feed_items_importation_types).join(","))
      flash[:notice] =I18n.t('workspace.edit.flash_notice')
		end

		response_for :destroy do |format|
			format.html { redirect_to administration_user_url(@current_user.id) }
		end
		
	end

  def add_new_user
		@current_object = Workspace.find(params[:id])
		no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
    @user = User.find(:first, :conditions => { :login => params[:user_login].split(' (').first })
    @uw = UsersWorkspace.new
    @uw.role_id = params[:user_role]
    @uw.user = @user
    render :update do |page|
      page.insert_html :bottom, 'users', :partial => 'user',  :object => @uw
    end
  end

  def current_object
    @current_object ||= @workspace =
      if params[:id]
        Workspace.find(params[:id])
      elsif params[:workspace_id]
        Workspace.find(params[:workspace_id])
      else
        nil
      end
  end

	def unsubscription
		@current_object = Workspace.find(params[:id])
		no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
		if UsersWorkspace.find(:first, :conditions => { :user_id => self.current_user.id, :workspace_id => params[:id] }).destroy
			flash[:notice] = I18n.t('workspace.unsubscription.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.unsubscription.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	def subscription
		@current_object = Workspace.find(params[:id])
		no_permission_redirection unless @current_object.accepts_show_for?(@current_user) && (@current_object.state == 'public')
		if UsersWorkspace.create(:user_id => self.current_user.id, :workspace_id => params[:id], :role_id => Role.find_by_name('reader').id)
			flash[:notice] = I18n.t('workspace.subscription.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.subscription.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	def question
		@current_object = Workspace.find(params[:id])
		no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
		if UserMailer.deliver_ws_administrator_request(Workspace.find(params[:id]).creator, @current_user.id, params[:question][:type], params[:question][:msg])
			flash[:notice] = I18n.t('workspace.question.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.question.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	
  def ajax_show 
      params[:id] ||= params[:workspace_id]
			params[:item_type] ||= (@current_object.ws_items.split(',') & @configuration['sa_items']).first.to_s.pluralize
			@current_objects = get_items_list(params[:item_type])
			@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
      render :partial=>"items/tab_list", :layout=>false
    end
end
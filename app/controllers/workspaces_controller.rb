class WorkspacesController < ApplicationController
  acts_as_ajax_validation

  make_resourceful do
    actions :show, :create, :new, :edit, :update

    before :show do
      no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
      params[:id] ||= params[:workspace_id]
    end

		before :new do
			no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
			@sa_conf = get_sa_config
			@ws_conf = WsConfig.find(1)
		end

		before :edit do
			no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
			@sa_conf = get_sa_config
			# in case no ws_config found
			if !@current_object.ws_config
        default = WsConfig.find(1)
				@current_object.ws_config = WsConfig.new(:ws_items => default.ws_items, :ws_feed_items_importation_types => default.ws_feed_items_importation_types)
				@current_object.save
			end
			@ws_conf = @current_object.ws_config
		end

    before :create do
			no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
			params[:id] ||= params[:workspace_id]
      @current_object.creator = @current_user
			@current_object.ws_config_id = WsConfig.first.id
    end
		after :create do
			#if current_user.is_superadmin?
				UsersWorkspace.create(:user_id => @current_user.id, :workspace_id => @current_object.id, :role_id => Role.find_by_name('ws_admin').id)
				default = WsConfig.find(1)
				@current_object.ws_config = WsConfig.create(:ws_items => default.ws_items, :ws_feed_items_importation_types => default.ws_feed_items_importation_types)
				#@current_object.ws_config = WsConfig.create(:ws_items => check_to_tab(:items).join(","), :ws_feed_items_importation_types => check_to_tab(:feed_items_importation_types).join(","))
				@current_object.save
        flash[:notice] =I18n.t('workspace.new.flash_notice')
			#end
		end
    after :create_fails do
      flash[:error] =I18n.t('workspace.new.flash_error')
    end

		before :update do
      no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
      # Hack. Permit deletion of all assigned users (with roles).
      params["workspace"]["existing_user_attributes"] ||= {}
    end
		after :update do
			@current_object.ws_config.update_attributes(:ws_items => check_to_tab(:items).join(","), :ws_feed_items_importation_types => check_to_tab(:feed_items_importation_types).join(","))
      flash[:notice] =I18n.t('workspace.edit.flash_notice')
		end
    after :update_fails do
      flash[:error] =I18n.t('workspace.edit.flash_error')
    end
    after :show do
			@current_object.ws_config.update_attributes(:ws_items => check_to_tab(:items).join(","), :ws_feed_items_importation_types => check_to_tab(:feed_items_importation_types).join(","))
      flash[:notice] =I18n.t('workspace.edit.flash_notice')
		end
	end

  def add_new_user
    @user = User.find_by_login(params[:user_login])
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
		if UsersWorkspace.find(:first, :conditions => { :user_id => self.current_user.id, :workspace_id => params[:id] }).destroy
			flash[:notice] = I18n.t('workspace.unsubscription.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.unsubscription.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	def subscription
		if UsersWorkspace.create(:user_id => self.current_user.id, :workspace_id => params[:id], :role_id => Role.find_by_name('reader').id)
			flash[:notice] = I18n.t('workspace.subscription.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.subscription.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	def question
		if UserMailer.deliver_ws_administrator_request(Workspace.find(params[:id]).creator, @current_user.id, params[:question][:type], params[:question][:msg])
			flash[:notice] = I18n.t('workspace.question.flash_notice')
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.question.flash_error')
			redirect_to workspace_path(params[:id])
		end
	end

	def ws_config
		if (WsConfig.exists?(params[:id]))
			@conf = WsConfig.find(params[:id])
		else
			@conf = WsConfig.new
		end
		return unless request.post?


	end

  def ajax_show 
      params[:id] ||= params[:workspace_id]
      render :partial=>"items/tab_list", :layout=>false
    end
end
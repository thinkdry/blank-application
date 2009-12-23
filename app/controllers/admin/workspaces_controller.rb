class Admin::WorkspacesController < Admin::ApplicationController

	# Mixin setting the permission for that controller (see lib/acts_as_authorizable.rb for more)
	acts_as_authorizable(
		:actions_permissions_links => {
					'new' => 'new',
					'create' => 'new',
					'edit' => 'edit',
					'update' => 'edit',
					'show' => 'show',
					'rate' => 'rate',
					'add_comment' => 'comment',
					'destroy' => 'destroy',
					'contacts_management' => 'contact_management',
					'add_contacts' => 'contacts_management',
					'add_new_user' => 'edit'
				},
		:skip_logging_actions => [])

  acts_as_container
  
  # Action to insert user field with role to the workspace (used with AJAX call)
  #
	# This action is just updating the form, not saving the entry.
	#
  # Usage URL :
  # POST /workspaces/add_new_user
  def add_new_user
		@current_object ||= Workspace.find(params[:id])
    @user = User.find_by_login(params[:user_login])
    @uw = UsersWorkspace.new(:role_id => params[:role_id].to_i, :user_id => @user.id)
    render :update do |page|
      if @user
        page.insert_html :bottom, 'users', :partial => 'user',  :object => @uw
      else
        page.call "alert","No user exist with #{params[:user_login]}"
      end
    end
  end

  # Action to leave the worksapce
	#
	# This action remove the entry linking the current workspace with the current user,
	# from UsersWorkspaces table
  #
  # Usage URL :
  # /workspaces/:id/unsubscription
	def unsubscription
		@current_object = Workspace.find(params[:id])
		if UsersWorkspace.find(:first, :conditions => { :user_id => self.current_user.id, :workspace_id => params[:id] }).destroy
			flash[:notice] = I18n.t('workspace.unsubscription.flash_notice')
			redirect_to admin_workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.unsubscription.flash_error')
			redirect_to admin_workspace_path(params[:id])
		end
	end

  # Action to join a workspace
  #
  # Usage URL :
  # GET /workspaces/:id/subscription
	def subscription
		@current_object = Workspace.find(params[:id])
		if UsersWorkspace.create(:user_id => self.current_user.id, :workspace_id => params[:id], :role_id => Role.find_by_name('reader').id)
			flash[:notice] = I18n.t('workspace.subscription.flash_notice')
			redirect_to admin_workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.subscription.flash_error')
			redirect_to admin_workspace_path(params[:id])
		end
	end

	# Action to send a request to the workspace administrator
	#
	# Usage URL :
	# - POST /workspaces/:id/question
	def question #:nodoc:
		@current_object = Workspace.find(params[:id])
		if UserMailer.deliver_ws_administrator_request(Workspace.find(params[:id]).creator, @current_user.id, params[:question][:type], params[:question][:msg])
			flash[:notice] = I18n.t('workspace.question.flash_notice')
			redirect_to admin_workspace_path(params[:id])
		else
			flash[:error] = I18n.t('workspace.question.flash_error')
			redirect_to admin_workspace_path(params[:id])
		end
	end

end

class WorkspacesController < ApplicationController
  acts_as_ajax_validation

  make_resourceful do
    actions :show, :create, :new, :edit, :update
    
    before :show do
      permit "consultation of current_object"
      params[:id] ||= params[:workspace_id]
    end

		before :new do
			@sa_conf = get_sa_config
			@ws_conf = WsConfig.find(1)
		end

		before :edit do
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
			params[:id] ||= params[:workspace_id]
      @current_object.creator = @current_user
			@current_object
    end

		after :create do
			#if current_user.is_superadmin?
				default = WsConfig.find(1)
				@current_object.ws_config = WsConfig.create(:ws_items => default.ws_items, :ws_feed_items_importation_types => default.ws_feed_items_importation_types)
				#@current_object.ws_config = WsConfig.create(:ws_items => check_to_tab(:items).join(","), :ws_feed_items_importation_types => check_to_tab(:feed_items_importation_types).join(","))
				@current_object.save
			#end
		end

		after :update do
			if current_user.is_superadmin?
				@current_object.ws_config.update_attributes(:ws_items => check_to_tab(:items).join(","), :ws_feed_items_importation_types => check_to_tab(:feed_items_importation_types).join(","))
			end
		end
    
    before :update do
      permit "edition of current_object"
      # Hack. Permit deletion of all assigned users (with roles).
      params["workspace"]["existing_user_attributes"] ||= {}
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
			flash[:notice] = "Vous êtes désinscrit de cet espace de travail."
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = "Vous n'avez pas été désinscrit de cet espace de travail."
			redirect_to workspace_path(params[:id])
		end
	end

	def subscription
		if UsersWorkspace.create(:user_id => self.current_user.id, :workspace_id => params[:id], :role_id => Role.find_by_name('reader').id)
			flash[:notice] = "Vous êtes inscrit sur cet espace de travail."
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = "Vous n'avez pas été inscrit sur cet espace de travail."
			redirect_to workspace_path(params[:id])
		end
	end

	def question
		if UserMailer.deliver_ws_administrator_request(Workspace.find(params[:id]).creator, @current_user.id, params[:question][:type], params[:question][:msg])
			flash[:notice] = "Votre demande a bien été envoyée."
			redirect_to workspace_path(params[:id])
		else
			flash[:error] = "Votre demande n'a pu être envoyée."
			redirect_to workspace_path(params[:id])
		end
	end

	def ws_config
		if (@conf=WsConfig.find(params[:id]))
		else
			@conf = WsConfig.new
		end
		return unless request.post?
		

	end
 
end
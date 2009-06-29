module ActsAsWorkspace
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # ActsAsWorkspace Library for Workspace Specific Code - Specific Controller Methods to all Workspaces
      def acts_as_workspace &block
        include ActsAsWorkspace::ControllerMethods::InstanceMethods
        
        make_resourceful do
          actions :all

          self.instance_eval &block if block_given?
          
          after :create do
            flash[:notice] = @current_object.class.label+' '+I18n.t('worskpace.new.flash_notice')
          end

          after :create_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('worskpace.new.flash_error')
          end

          after :update do
            flash[:notice] = @current_object.class.label+' '+I18n.t('worskpace.edit.flash_notice')
          end
          
           after :update_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('worskpace.edit.flash_error')
          end

          before :new, :create do
            no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
          end

          before :show, :index do
            no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
          end

          before :edit, :update do
            no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
          end

          before :destroy do
            no_permission_redirection unless @current_object.accepts_destroy_for?(@current_user)
          end
                    
          # Makes `current_user` as author for the current_object
          before :create do
            current_object.creator_id = current_user.id
          end
					
					response_for :show do |format|
						format.html # show.html.erb
						format.xml { render :xml => @current_object }
						format.json { render :json => @current_object }
	        end

					response_for :index do |format|
						format.html # index.html.erb
						format.xml { render :xml => @current_objects }
						format.json { render :json => @current_objects }
						format.atom # index.atom.builder
	        end
					
        end
      end
    end
    
    module InstanceMethods
      # Assign Users with role to Workspace in UsersWorkspace
			def add_new_user
				@current_object = Workspace.find(params[:id])
				no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
				@user = User.find(:first, :conditions => { :login => params[:user_login] })
				@uw = UsersWorkspace.new
				@uw.role_id = params[:user_role]
				@uw.user = @user
				render :update do |page|
					page.insert_html :bottom, 'users', :partial => 'user',  :object => @uw
				end
			end

      # Return Workspace Object for workspace parameters
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

		end

  end
end
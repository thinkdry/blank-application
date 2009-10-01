# This librairy will define methods allowing to control easily the authorization
# on action (controller part) and on object (model part).
#
module Authorizable

  module ControllerMethods

		# Mixin concept : The ClassMethods defined after are automatically inside the class/module
		# where you are including that module.
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			# This mixin method will : 
			# - set the action skipping the logging part
			# - define the method checking the permission depending of the action
			# - set this method as a before_filter
			def acts_as_authorizable(*args)
				options = args.extract_options!
				skip_before_filter :is_logged?, :only => options[:skip_logging_actions]
				before_filter :permission_checking
				define_method :permission_checking do
					if options[:actions_permissions_links][params[:action]]
						obj = params[:controller].classify.constantize
						@current_object = ['new', 'create','validate'].include?(params[:action]) ? obj.new : obj.find(params[:id])
						#no_permission_redirection unless @current_user && @current_object.send("accepts_#{hash[params[:action]]}_for?".to_sym, @current_user)
						no_permission_redirection unless @current_user && @current_object.has_permission_for?(options[:actions_permissions_links][params[:action]], @current_user)
					else
						# it is permissive
					end
				end
				include Authorizable::ControllerMethods::InstanceMethods
      end
    end
    
    module InstanceMethods
    end
		
  end
end

module Authorizable
  module ModelMethods

		# Mixin concept
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
			# This mixin method will manage different inclusion regarding the type of the object calling it , so :
			# - define the scope useful to get objects list depending on permissions and workspaces
			# - include the specific instance methods allowing to check permission on an object instance
      def acts_as_authorizable
				include Authorizable::ModelMethods::InstanceMethods
				if ITEMS.include?(self.to_s.underscore)
					named_scope :matching_user_with_permission_in_workspaces, lambda { |user, permission, workspace_ids|
						# Check if these workspace are matching the really authorized ones, and set 'nil for all' condition
						workspace_ids ||= Workspace.allowed_user_with_permission(user, self.to_s.underscore+'_'+permission).all(:select => 'workspaces.id').map{ |e| e.id }
						workspace_ids = workspace_ids.map{|w_id| w_id.to_i} & Workspace.allowed_user_with_permission(user, self.to_s.underscore+'_'+permission).all(:select => 'workspaces.id').map{ |e| e.id }
						# So we can retrieve directly as the workspaces are checked, hihihi
						if workspace_ids.first
              
							{ :select => "DISTINCT #{self.to_s.underscore.pluralize}.*",
								:joins => "LEFT JOIN items_workspaces ON #{self.to_s.underscore.pluralize}.id = items_workspaces.itemable_id AND items_workspaces.itemable_type='#{self.to_s}'",
								:conditions => "items_workspaces.workspace_id IN (#{workspace_ids.join(',')})" }
						else
						# In order to return nothing ...
							{ :conditions => "1=2"}
						end
						}
					include Authorizable::ModelMethods::IMItem
				elsif ['workspace'].include?(self.to_s.underscore)
					named_scope :matching_user_with_permission_in_workspaces, lambda { |user, permission, workspace_ids|
						# Check if these workspace are matching the really authorized ones, and set 'nil for all' condition
            workspace_ids ||= Workspace.allowed_user_with_permission(user, self.to_s.underscore+'_'+permission).all(:select => 'workspaces.id').map{ |e| e.id }
						workspace_ids = workspace_ids.map{|w_id| w_id.to_i} & Workspace.allowed_user_with_permission(user, self.to_s.underscore+'_'+permission).all(:select => 'workspaces.id').map{ |e| e.id }
            
						# In case of system permission
						if user.has_system_permission(self.to_s.underscore.pluralize, permission)
							{ }
						# So we can retrieve directly as the workspaces are checked, hihihi
						elsif workspace_ids.first
							{ 
                :conditions => "id IN (#{workspace_ids.join(',')})"
              }
						else
						# In order to return nothing ...
							{ :conditions => "1=2"}
						end
						}
					# Scope getting the workspaces authorized for an user with a specific permission
					named_scope :allowed_user_with_permission, lambda { |user, permission_name|
						raise 'User required' unless user
						raise 'Permission name' unless permission_name
						if user.has_system_role('superadmin')
							{ :order => "workspaces.title ASC" }
						else
							{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user.id.to_i} "+
									"LEFT JOIN permissions_roles ON permissions_roles.role_id = users_workspaces.role_id "+
									"LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id",
								:conditions => "permissions.name = '#{permission_name.to_s}'" ,
								:select => "DISTINCT workspaces.*",
								:order => "workspaces.title ASC"
							}
						end
					}

					# Scope getting the workspaces authorized for an user with a specific role
					named_scope :allowed_user_with_ws_role, lambda { |user, role_name|
						raise 'User required' unless user
						raise 'Role name' unless role_name
						{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user.id.to_i} "+
								"LEFT JOIN roles ON roles.id = users_workspaces.role_id",
							:conditions => "roles.name = '#{role_name.to_s}'" ,
							:select => "DISTINCT workspaces.*",
							:order => "workspaces.title ASC"
						}
					}
					include Authorizable::ModelMethods::IMWorkspace
				elsif self.to_s.underscore == 'user'
					named_scope :matching_user_with_permission_in_workspaces, lambda { |user, permission, workspace_ids|
						# Check if these workspace are matching the really authorized ones, and set 'nil for all' condition
						workspace_ids ||= Workspace.allowed_user_with_permission(user, self.to_s.underscore+'_'+permission).all(:select => 'workspaces.id').map{ |e| e.id }
						workspace_ids = workspace_ids & Workspace.allowed_user_with_permission(user, self.to_s.underscore+'_'+permission).all(:select => 'workspaces.id').map{ |e| e.id }
						# In case of system permission
						if user.has_system_permission(self.to_s.underscore.pluralize, permission)
							{  }
						# So we can retrieve directly as the workspaces are checked, hihihi
						elsif workspace_ids.first
							{ :select => "DISTINCT #{self.to_s.underscore.pluralize}.*",
								:joins => "LEFT JOIN users_workspaces ON #{self.to_s.underscore.pluralize}.id = users_workspaces.user_id",
								:conditions => "users_workspaces.workspace_id IN (#{workspace_ids.join(',')})" }
						else
						# In order to return nothing ...
							{ :conditions => "1=2"}
						end
						}
					include Authorizable::ModelMethods::IMUser
				end
			end
    end

    module InstanceMethods
			# Generic method called on an instance to check if the permission is matching or no
			def has_permission_for?(permission, user)
				return accepting_action(user, permission)
			end
		end
		
		module IMUser
				def accepting_action(user, action, spe_cond=false, sys_cond=false, ws_cond=true)
					# Special access
					if user.has_system_role('superadmin') || (self.id && ['show', 'edit'].include?(action)) || spe_cond
						return true
					end
					# System access
					if user.has_system_permission(self.class.to_s.downcase, action) || sys_cond
						return true
					end
					# Workspace access
					# The only permission linked to an user in a workspace is 'show'
					if action=='show'
						self.workspaces.each do |ws|
							if ws.users.include?(user)
								if user.has_workspace_permission(ws.id, self.class.to_s.downcase, action) && ws_cond
									return true
								end
							end
						end
					end
					false
				end
		end

		module IMWorkspace
			def accepting_action(user, action, spe_cond=false, sys_cond=false, ws_cond=true)
				# Special access
				if user.has_system_role('superadmin') || spe_cond
					return true
				end
				# System access
				if user.has_system_permission(self.class.to_s.downcase, action) || sys_cond
					return true
				end
				# Workspace access
				# Not for new and index normally ...
				if self.users.include?(user)
					if user.has_workspace_permission(self.id, self.class.to_s.downcase, action) && ws_cond
						return true
					end
				end
				false
			end
		end

		module IMItem
			def get_sa_config
				if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
					return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
				else
					return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
				end
			end

			def accepting_action(user, action, active=true)
				model_name = self.class.to_s
				# Special stuff
				if !get_sa_config['sa_items'].include?(model_name.underscore) || !active
					return false
				end
        # System access
				if user.has_system_permission(model_name.downcase, action)
					return true
				end
        # Workspace access
				if self.id.nil?
					wsl = user.workspaces
					# no good, but lazy today
					cats = get_sa_config['sa_items']
				else
					wsl = self.workspaces & user.workspaces
					#p self.category
					#cats = self.category.to_s.split(',')
				end
        wsl.each do |ws|
					# First of all, to check if this workspace accpets these items
					if ws.ws_items.to_s.split(',').include?(model_name.underscore)
						# Then with workspace full access
						if user.has_workspace_permission(ws.id, model_name.underscore, action)
							return true
						end
					end # if item available in ws
				end
				# go away
				false

			end
		end
		
  end
end

module Authorized
  module ModelMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			def acts_as_authorized
				# Relation N-1 getting workspace Role objects through the 'users_workspaces' table
				has_many :workspace_roles, :through => :users_workspaces, :source => :role

				include Authorized::ModelMethods::InstanceMethods
      end

    end
    
    module InstanceMethods
				# User System Role for Permissions
				#
				# Usage:
				#
				# <tt>user.system_role</tt>
				#
				# will return the role object of the system role
				#
				def system_role
					return Role.find(self.system_role_id)
				end

				# Check User for System role with passed 'role'
				#
				# Usage:
				#
				# <tt>user.has_system_role('admin')</tt>
				#
				# will return true if the user has role 'admin' or if he is superadmin
				#
				def has_system_role(role_name)
					return (self.system_role.name == role_name) || self.system_role.name == 'superadmin'
				end

				# Check User for Workspace Role with passed 'workspace' & 'role_type'
				#
				# Usage:
				#
				# <tt>user.has_workspace_role('ws_admin')</tt>
				#
				# will return true if the user has role 'ws_admin' for workspace or if he is superadmin
				#
				def has_workspace_role(workspace_id, role_name)
					return UsersWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id, :role_id => Role.find_by_name(role_name).id) || self.system_role.name == 'superadmin'
				end

				# Users System Permissions
				#
				# Usage:
				#
				# <tt>user.system_permissions</tt>
				#
				# will return all the permissions for the user system role
				#
				def system_permissions
					return self.system_role.permissions
				end

				# Users Workspace Permissions
				# Users System Permissions
				#
				# Usage:
				#
				# <tt>user.workspace_permissions</tt>
				#
				# will return all the permissions for the user workspace role for given workspace
				#
				def workspace_permissions(workspace_id)
					if UsersWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id)
						return UsersWorkspace.find(:first, :conditions => {:user_id => self.id, :workspace_id => workspace_id}).role.permissions
					else
						return []
					end
				end

				# User System Role for Controller and Action
				#
				# Usage:
				#
				# <tt>user.has_system_permission('workspaces','new')</tt>
				#
				# will return true if the user has system permission to create new workspace
				#
				def has_system_permission(controller, action)
					permission_name = controller+'_'+action
					return !self.system_permissions.delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
				end

				# User Worksapce Role for Given Worksapce, Controller and Action
				#
				# Usage:
				#
				# <tt>user.has_workspace_permission('articles','new')</tt>
				#
				# will return true if the user has workspace permission to create new article
				#
				def has_workspace_permission(workspace_id, controller, action)
					permission_name = controller+'_'+action
					return !self.workspace_permissions(workspace_id).delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
				end
      
    end
  end
end
# This module will defined the methods allowing to check easily the roles and permissions
# link to an object, in our case a User object linked to workspaces (or no).
#
module Authorized
  module ModelMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			# Mixin method setting the relation N-1 getting workspace Role objects through the 'users_workspaces' table
			# and including instance methods usefull to get roles and permissions.
			def acts_as_authorized
				# Relation N-1 getting workspace Role objects through the 'users_workspaces' table
				has_many :workspace_roles, :through => :users_workspaces, :source => :role

				include Authorized::ModelMethods::InstanceMethods
      end

    end
    
    module InstanceMethods
				# Method returning the system role
				#
				# Usage :
				# <tt>user.system_role</tt>
				def system_role
					return Role.find(self.system_role_id)
				end

				# Method returning true if the user has the system role passed in params, false else
				#
				# Parameters :
				# - role_name: String defining the role
				#
				# Usage :
				# <tt>user.has_system_role('admin')</tt>
				def has_system_role(role_name)
					return (self.system_role.name == role_name) || self.system_role.name == 'superadmin'
				end

				# Method returning true if the user has the workspace role passed in params, false else
				#
				# Parameters :
				# - workspace_id: Integer for workspace id
				# - role_name: String defining the role
				#
				# Usage:
				# <tt>user.has_workspace_role('ws_admin')</tt>
				def has_workspace_role(workspace_id, role_name)
					return UsersWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id, :role_id => Role.find_by_name(role_name).id) || self.system_role.name == 'superadmin'
				end

				# Method returning the system permissions list
				#
				# Usage :
				# <tt>user.system_permissions</tt>
				def system_permissions
					return self.system_role.permissions
				end

				# Method returning the workspace permissions list
				#
				# Parameters :
				# - workspace_id: Integer defining the workspace id
				#
				# Usage :
				# <tt>user.workspace_permissions(2)</tt>
				def workspace_permissions(workspace_id)
					if UsersWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id)
						return UsersWorkspace.find(:first, :conditions => {:user_id => self.id, :workspace_id => workspace_id}).role.permissions
					else
						return []
					end
				end

				# Method returning true if user has the system permission, false else
				#
				# Parameters :
				# - controller: String defining the controller defining the first part of the permission
				# - action: String defining the action defining the second part of the permission
				#
				# Usage :
				# <tt>user.has_system_permission('workspaces','new')</tt>
				def has_system_permission(controller, action)
					permission_name = controller+'_'+action
					return !self.system_permissions.delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
				end

				# Method returning true if user has the workspace permission, false else
				#
				# Parameters :
				# - workspace_id: Integer for workspace id
				# - controller: String defining the controller defining the first part of the permission
				# - action: String defining the action defining the second part of the permission
				#
				# Usage :
				# <tt>user.has_workspace_permission('articles','new')</tt>
				def has_workspace_permission(workspace_id, controller, action)
					permission_name = controller+'_'+action
					return !self.workspace_permissions(workspace_id).delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
				end

    end
  end
end
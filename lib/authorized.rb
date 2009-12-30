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
				has_many :container_roles, :through => :users_containers, :source => :role
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
				def has_container_role(container_id, container, role_name)
					return UsersContainer.exists?(:user_id => self.id, :containerable_id => container_id, :containerable_type => container.capitalize, :role_id => Role.find_by_name(role_name).id) || self.system_role.name == 'superadmin'
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
				def container_permissions(container_id, container)
					if UsersContainer.exists?(:user_id => self.id, :containerable_id => container_id, :containerable_type => container)
						return UsersContainer.find(:first, :conditions => {:user_id => self.id, :containerable_id => container_id, :containerable_type => container}).role.permissions
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
				# <tt>user.has_workspace_permission('workspace_id','articles','new')</tt>
				def has_container_permission(container_id, controller, action, container)
					permission_name = controller+'_'+action
					return !self.container_permissions(container_id,container).delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
				end

    end
  end
end

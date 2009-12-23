# == Schema Information
# Schema version: 20181126085723
#
# Table name: roles
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  type_role   :string(255)
#

# This object is dealing with the roles inside the Blank application.
# There are two kinds of role, defined with the 'type_role' attribute :
# - the 'system' role used to check permissions inside the whole application
# - the 'workspace' role use to check permissions inside a workspace
#
# You have to see a role as a set of permissions, used to manage the rights inside the application.
#
class Role < ActiveRecord::Base

	# Relation N-N with the 'permissions' table
  has_and_belongs_to_many :permissions
  # Relation N-1 with the table 'users_workspaces', setting the Role for an User inside a Workspace
  has_many :users_containers, :dependent => :delete_all
	# Relation N-1 retrieving the users from the 'users_worlspaces' table
	has_many :users, :through => :users_containers
	# Relation N-1 retrieving the workspaces from the 'users_worlspaces' table
  CONTAINERS.each do |container|
    has_many container.pluralize.to_sym, :through => :users_containers
  end
	# Validation of the rpesence of these fields
	validates_presence_of :name, :type_role
	# Validation of the uniqueness of this field
	validates_uniqueness_of :name
  
  named_scope :of_type,lambda {|role_type|
    {:conditions => {:type_role => role_type}}
  }


  named_scope :of_type,lambda {|role_type|
    {:conditions => {:type_role => role_type}}
  }

  def set_permissions(permissions)
    self.permissions.delete_all
    permissions.each { |k, v| self.permissions << Permission.find(k.to_i) }
  end

end

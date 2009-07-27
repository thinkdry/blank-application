# == Schema Information
# Schema version: 20181126085723
#
# Table name: items
#
#  id            :integer(4)      not null, primary key
#  itemable_type :string(255)
#  itemable_id   :integer(4)
#  workspace_id  :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

# This object is used to define the relation between Workspace and item types, so it is a polymorphic relation.
#
class Item < ActiveRecord::Base

	# Relation 1-N with the 'workspaces' table
  belongs_to :workspace
	# Polymorphic relation with the items tables
  belongs_to :itemable, :polymorphic => true, :include => :user

  # Method retreiving the item object using the polymorphic relation
	def get_item #:nodoc:
		return self.itemable_type.classify.constantize.find(self.itemable_id)
	end

  # Method retrieving the title of the item object
	def title #:nodoc:
		return self.get_item.title
	end

  # Method retrieving the title of the description object
	def description #:nodoc:
		return self.get_item.description
	end

  # Scope retrieving the items list dependng of the workspace and the user
	named_scope :allowed_user_with_permission_in_workspace, lambda { |user_id, permission_name, workspace_ids|
		raise 'User required' unless user_id
		raise 'Permission name' unless permission_name
		if User.find(user_id).has_system_role('superadmin')
			{ }
		else
			{ :select => 'DISTINCT items.*',
				:joins => #"LEFT JOIN workspaces ON items.workspace_id IN (#{workspace_ids.split(',')}) "+
						"LEFT JOIN users_workspaces ON users_workspaces.workspace_id IN (#{workspace_ids.split(',')}) AND users_workspaces.user_id = #{user_id.to_i} "+
						"LEFT JOIN permissions_roles ON permissions_roles.role_id = users_workspaces.role_id "+
						"LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id",
				:conditions => "permissions.name LIKE '%#{permission_name.to_s}'" }
		end
	}

end


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

class Item < ActiveRecord::Base

  belongs_to :workspace

  belongs_to :itemable, :polymorphic => true, :include => :user

  # Current Item Type
	def get_item
		return self.itemable_type.classify.constantize.find(self.itemable_id)
	end

  # Current Item Type Title
	def title
		return self.get_item.title
	end

  # Current Item Type Description
	def description
		return self.get_item.description
	end

  # Permission for User in given Worksapce
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


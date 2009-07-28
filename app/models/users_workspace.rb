# == Schema Information
# Schema version: 20181126085723
#
# Table name: users_workspaces
#
#  id           :integer(4)      not null, primary key
#  workspace_id :integer(4)
#  role_id      :integer(4)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

# This object is used to define the relation between Workspace and User.
# It is actually a join table with the 'roles' table also,
# because yo have to set a role for an user in a workspace.
#
class UsersWorkspace < ActiveRecord::Base

	# Relation 1-N with the 'users' table
	belongs_to :user
	# Relation 1-N with the 'workspaces' table
	belongs_to :workspace
	# Relation 1-N with the 'roles' table
	belongs_to :role
	# Validation of the presence of these fields
	validates_presence_of :user_id, :role_id, :workspace_id
  # Validation of the uniqueness of this field
	validates_uniqueness_of :user_id, :scope => :workspace_id

end

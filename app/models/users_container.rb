class UsersContainer < ActiveRecord::Base

  # Relation 1-N with the 'users' table
	belongs_to :user
	# Relation 1-N with the 'workspaces' table
	belongs_to :containerable, :polymorphic => true
	# Relation 1-N with the 'roles' table
	belongs_to :role
	# Validation of the presence of these fields
	validates_presence_of :user_id, :role_id, :containerable_id, :containerable_type
  # Validation of the uniqueness of this field
	validates_uniqueness_of :user_id, :scope => [:containerable_id, :containerable_type]


end

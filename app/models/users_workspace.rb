class UsersWorkspace < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :workspace
	belongs_to :role
	
	validates_presence_of :workspace_id, :user_id, :role_id
	validates_uniqueness_of :user_id, :scope => :workspace_id
	
end

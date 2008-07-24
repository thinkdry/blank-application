class UsersWorkspace < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :workspace
	belongs_to :role
	
end

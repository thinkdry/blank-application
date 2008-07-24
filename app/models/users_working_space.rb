class UsersWorkingSpace < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :working_space
	belongs_to :role
	
end

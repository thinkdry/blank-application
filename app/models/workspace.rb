class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces
	has_many :users, :through => :users_workspaces
	has_many :roles, :through => :users_workspaces
	
	validates_presence_of :name
	
end

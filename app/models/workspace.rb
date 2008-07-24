class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces
	has_many :users, :through => :users_workspaces
	
	validates_presence_of :name
	validates_associated  :users_workspaces
end

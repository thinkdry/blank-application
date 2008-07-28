class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces, :dependent => :delete_all
	has_many :users, :through => :users_workspaces
	
	has_many :items, :dependent => :delete_all
  has_many_polymorphs :itemables, :from => [:artic_files], :through => :items
	
	validates_presence_of :name
	validates_associated :users_workspaces

end

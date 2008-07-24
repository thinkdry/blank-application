class Role < ActiveRecord::Base
	
	has_many :permissions_roles
	has_many :permissions, :through => :permissions_roles
	has_many :users_working_spaces
	has_many :users, :through => :users_working_spaces
	has_many :users_working_spaces
	has_many :working_spaces, :through => :users_working_spaces
	
	validates_presence_of :name
	
end

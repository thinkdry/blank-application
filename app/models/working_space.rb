class WorkingSpace < ActiveRecord::Base
	
	has_many :users_working_spaces
	has_many :users, :through => :users_working_spaces
	has_many :roles, :through => :users_working_spaces
	
	validates_presence_of :name
	
end

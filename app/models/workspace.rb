class Workspace < ActiveRecord::Base
	
	has_many :users_working_spaces
	has_many :users, :through => :users_working_spaces
	
	validates_presence_of :name
	validates_associated  :user_working_spaces
	
end

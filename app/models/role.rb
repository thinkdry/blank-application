# == Schema Information
# Schema version: 20181126085723
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
	
	has_many :permissions_roles, :dependent => :delete_all
	has_many :permissions, :through => :permissions_roles
	has_many :users_workspaces, :dependent => :delete_all
	has_many :users, :through => :users_workspaces
	has_many :workspaces, :through => :users_workspaces
	
	validates_presence_of :name
	
end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: roles
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Role < ActiveRecord::Base
	
	# a role can have many permissions, and a permission can have many roles
  has_and_belongs_to_many :permissions
  # a user can have many workspaces with different roles
  has_many :users_workspaces, :dependent => :delete_all
	has_many :users, :through => :users_workspaces
	has_many :workspaces, :through => :users_workspaces
	
	validates_presence_of :name
	validates_uniqueness_of :name
  validates_presence_of :type_role
	
  def self.find_by_type_role(role)
    self.find(:all, :conditions => {:type_role => role})
  end

  

	
end

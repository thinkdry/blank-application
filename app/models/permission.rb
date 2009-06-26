# == Schema Information
# Schema version: 20181126085723
#
# Table name: permissions
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Permission < ActiveRecord::Base
  
  # a role can have many permissions, and a permission can have many roles
  has_and_belongs_to_many :roles
  
  validates_presence_of :name

  validates_uniqueness_of :name

  validates_presence_of :type_permission
  
end

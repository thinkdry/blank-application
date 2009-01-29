# == Schema Information
# Schema version: 20181126085723
#
# Table name: system_roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SystemRole < ActiveRecord::Base
	
  has_many :users

end

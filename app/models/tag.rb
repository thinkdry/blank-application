# == Schema Information
# Schema version: 20181126085723
#
# Table name: tags
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base
  
  has_many :taggings

	def get_object_linked
		self.taggings.map{ |e| e.taggable }
	end

end

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

class Keyword < ActiveRecord::Base
  has_many :keywordings

	def get_object_linked
		self.keywordings.map{ |e| e.keywordable }
	end

end

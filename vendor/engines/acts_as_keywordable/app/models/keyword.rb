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

# This class is used to manage the Keyword objects.
# Keywords allowed to add sense to an object.
#
class Keyword < ActiveRecord::Base

	# Relation N-1 to the 'keywordings' table
  has_many :keywordings

	# Method retrieving the objects linked to a keyword
	def get_object_linked
		self.keywordings.map{ |e| e.keywordable }
	end

end

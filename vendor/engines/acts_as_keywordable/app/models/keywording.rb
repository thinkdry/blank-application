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

# This class is used to manage the relation between a Keyword object and his relative object.
#
class Keywording < ActiveRecord::Base

	# Relation 1-N with the 'keywords' table
	belongs_to :keyword
	# Polymorphic relation definition
  belongs_to :keywordable, :polymorphic => true

end

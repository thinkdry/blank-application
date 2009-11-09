# == Schema Information
# Schema version: 20181126085723
#
# Table name: groups_newsletters
#
#  id            :integer(4)      not null, primary key
#  newsletter_id :integer(4)
#  group_id      :integer(4)
#  sent_on       :datetime
#

# This object is used to manage the join between Newsletter object and Group object.
# It is defined just to support the double :has_many relationship.
class GroupsNewsletter < ActiveRecord::Base

	# Realtion 1-N with 'groups' table
  belongs_to :group
  # Relation 1-N with 'newsletters' table
  belongs_to :newsletter
  
end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: groupings
#
#  group_id       :integer(4)
#  groupable_id   :integer(4)
#  groupable_type :string(255)
#  user_id        :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

# This object is used to managed the different objects belonging to a group.
# It is using a polymorphic relation because these objects can be of different types (User, Person, ...).
class Grouping < ActiveRecord::Base

	# Relation 1-N with 'groups' table
  belongs_to :group
	# Polymorphic relation definition
  belongs_to :contacts_workspace

#  # Method getting the instance of the object defined by the Grouping object
#  def member
#		m = self.contacts_workspace
#    return m.contactable_type.classify.constantize.find(m.contactable_id)
#  end

end

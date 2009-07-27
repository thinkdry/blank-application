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
  belongs_to :groupable, :polymorphic => true
	# Relation with the 'users' table using the polymorphic definition
  belongs_to :user, :class_name => "User", :foreign_key => "groupable_id"
	# Relation with the 'people' table using the polymorphic definition
  belongs_to :person, :class_name => "Person", :foreign_key => "groupable_id"

  # Method getting the instance of the object defined by the Grouping object
  def member
    self.groupable_type.classify.constantize.find(self.groupable_id)
  end

end

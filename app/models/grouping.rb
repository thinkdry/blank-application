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

class Grouping < ActiveRecord::Base

  belongs_to :group

  belongs_to :groupable, :polymorphic => true

  belongs_to :user,  :class_name => "User", :foreign_key => "groupable_id"

  belongs_to :person,     :class_name => "Person", :foreign_key => "groupable_id"

  # Member object Depending on group. Members can be People or Users
  def member
    self.groupable_type.classify.constantize.find(self.groupable_id)
  end

end

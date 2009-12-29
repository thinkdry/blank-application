# == Schema Information
# Schema version: 20181126085723
#
# Table name: items
#
#  id            :integer(4)      not null, primary key
#  itemable_type :string(255)
#  itemable_id   :integer(4)
#  workspace_id  :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

# This object is used to define the relation between Workspace and item types, so it is a polymorphic relation.
#
class ItemsWorkspace < ActiveRecord::Base

 acts_as_items_container
 
end


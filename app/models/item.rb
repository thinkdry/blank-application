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

class Item < ActiveRecord::Base

  belongs_to :workspace
  belongs_to :itemable, :polymorphic => true, :include => :user


	def get_item
		return self.itemable_type.classify.constantize.find(self.itemable_id)
	end

	def title
		return self.get_item.title
	end

	def description
		return self.get_item.description
	end

end


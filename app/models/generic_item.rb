# == Schema Information
# Schema version: 20181126085723
#
# Table name: generic_items
#
#  item_type          :string(10)      default(""), not null
#  id                 :integer(4)      default(0), not null, primary key
#  user_id            :integer(4)
#  user_name          :text(2147483647
#  title              :string(255)
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#  number_of_comments :integer(8)
#  workspace_titles   :string(341)
#  average_rate       :decimal(14, 4)
#

# This object is linked to an SQL view (called 'generic_items').
#
# It is loading all the common fields of all the items of the databse inside an SQL view,
# allowing to get results on multiple models list easily.
class GenericItem < ActiveRecord::Base

  #View to Get Items
	self.inheritance_column = :item_type

	# Code building the scopes allowing to retrieve the different item types from the SQL view
	ITEMS.each do |item|
		named_scope item.pluralize.to_sym,
			:conditions => { :item_type => item.camelize }
	end

  # Items from given Worksapce
  named_scope :from_workspace, lambda { |ws_id|
		if ws_id
			{ :select => 'generic_items.*',
				:joins => 'LEFT JOIN items ON generic_items.item_type = items.itemable_type AND generic_items.id = items.itemable_id',
				:conditions => "items.workspace_id = #{ws_id}"
			}
		else
			{ :select => 'generic_items.*',
				:joins => 'LEFT JOIN items ON generic_items.item_type = items.itemable_type AND generic_items.id = items.itemable_id'
			}
		end
  }
	
  # Items from given User
  named_scope :consultable_by, lambda { |user_id|
    raise 'User expected' unless user_id
    if User.find(user_id).has_system_role('superadmin')
			{ }
		else
			{ :conditions => %{
        ( SELECT count(*)
          FROM items, users_workspaces
          WHERE
            items.itemable_type = generic_items.item_type AND
            items.itemable_id = generic_items.id AND
            users_workspaces.workspace_id = items.workspace_id AND
            users_workspaces.user_id = #{user_id} ) > 0 }}
		end
	}

  # 5 Most Commented Items
  named_scope :most_commented,
    :order => 'generic_items.number_of_comments DESC',
    :limit => 5

  # 5 Best Rated Items
  named_scope :best_rated,
    :order => 'generic_items.average_rate DESC',
    :limit => 5
   # 5 latest Items
  named_scope :latest,
    :order => 'generic_items.created_at DESC',
    :limit => 5
  # Latest Created
  named_scope :created,
    :order => 'generic_items.created_at DESC'
  # Latest Commented
  named_scope :commented,
    :order => 'generic_items.number_of_comments DESC'
  # Latest Rated
  named_scope :rated,
    :order => 'generic_items.average_rate DESC'
	
end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: feed_items
#
#  id             :integer(4)      not null, primary key
#  feed_source_id :integer(4)
#  guid           :string(255)
#  title          :string(255)
#  description    :text
#  authors        :string(255)
#  date_published :datetime
#  last_updated   :datetime
#  enclosures     :string(255)
#  link           :string(1024)
#  categories     :string(255)
#  copyright      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

# This object is managing the items present inside a Web feed.
#
# It allows to save the different items inside the database,
# to filter it easily and also to get new content easily.
#
# This object is considered actually as an Item of the Blank application,
# but a functionnality allows you to import a feed item as a Bookmark object,
# that is the trick to really got the information of a feed item inside the CMS.
class FeedItem < ActiveRecord::Base

	# Relation N-1 with the 'feed_sources' table
  belongs_to :feed_source

	# Scope getting the latest 5 feed items entered inside the database
  named_scope :latest,
    :order => 'last_updated DESC',
    :limit => 5

  # Scope getting the feed items for a specific workspace
	named_scope :from_workspace, lambda { |ws_id|
    raise 'WS expected' unless ws_id
    { :select => 'feed_items.*',
      :joins => "LEFT JOIN users_workspaces ON users_workspaces.user_id = #{ws_id} "+
				"INNER JOIN items ON items.workspace_id = users_workspaces.workspace_id AND items.itemable_type = 'FeedSource' "+
				"INNER JOIN feed_sources ON feed_sources.id = items.itemable_id OR feed_sources.user_id = #{ws_id}",
			:conditions => "feed_items.feed_source_id = feed_sources.id"
    }
  }

  # Scope getting the feed items for a specific user
  named_scope :consultable_by, lambda { |user_id|
    raise 'User expected' unless user_id
    return { } if User.find(user_id).has_system_role('superadmin')
    { :select => 'feed_items.*',
      :joins => "LEFT JOIN items ON items.workspace_id = #{user_id} AND items.itemable_type = 'FeedSource' LEFT JOIN feed_sources ON feed_sources.id = items.itemable_id ",
      :conditions => "feed_items.feed_source_id = feed_sources.id"
    }
  }

end

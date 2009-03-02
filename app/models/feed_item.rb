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

class FeedItem < ActiveRecord::Base

	include ActionView::Helpers
	include ActionView::Helpers::SanitizeHelper

  belongs_to :feed_source
  
  named_scope :latest,
    :order => 'last_updated DESC',
    :limit => 10
  
  def description=(value)
    # Remove html tags from description
    #value = strip_tags(value)

		# Clean first characters maching
		# Related Articles
		# (...)
		# Authors:  (...)
    #value.slice!(/\A[\n\t]*Related Articles.+Authors:[^\n]+\s+/m)

    # Remove last characters matching
    #   PMID: 123445
    #   [PubMed - as supplied by publisher]
    #value.slice!(/[\n\s]*PMID: \d+ \[PubMed - as supplied by publisher\][\n\s]*\Z/m)

    # After our cleaning, call the super method that will assignate the value
    super(value)
  end

	named_scope :from_workspace, lambda { |ws_id|
    raise 'WS expected' unless ws_id
    { :select => 'feed_items.*',
      :joins => "LEFT JOIN users_workspaces ON users_workspaces.user_id = #{ws_id} "+
				"INNER JOIN items ON items.workspace_id = users_workspaces.workspace_id AND items.itemable_type = 'FeedSource' "+
				"INNER JOIN feed_sources ON feed_sources.id = items.itemable_id OR feed_sources.user_id = #{ws_id}",
			:conditions => "feed_items.feed_source_id = feed_sources.id"
    }
  }

  named_scope :consultable_by, lambda { |user_id|
    raise 'User expected' unless user_id
    return { } if User.find(user_id).has_system_role('superadmin')
    { :select => 'feed_items.*',
      :joins => "LEFT JOIN items ON items.workspace_id = #{user_id} AND items.itemable_type = 'FeedSource' LEFT JOIN feed_sources ON feed_sources.id = items.itemable_id ",
      :conditions => "feed_items.feed_source_id = feed_sources.id"
    }
  }


end

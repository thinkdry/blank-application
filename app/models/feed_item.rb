include ActionView::Helpers::SanitizeHelper

class FeedItem < ActiveRecord::Base

  belongs_to :feed_source
  
  named_scope :latest,
    :order => 'last_updated DESC',
    :limit => 10
  
  #def description=(value)
    # Remove html tags from description
    #value = strip_tags(value)
    
    # Clean first characters maching
    #     Related Articles
    #     (...)
    #     Authors:  (...)
 #   value.slice!(/\A[\n\t]*Related Articles.+Authors:[^\n]+\s+/m)
    
    # Remove last characters matching
    #   PMID: 123445
    #   [PubMed - as supplied by publisher]
#    value.slice!(/[\n\s]*PMID: \d+ \[PubMed - as supplied by publisher\][\n\s]*\Z/m)
    
    # After our cleaning, call the super method that will assignate the value
#    super(value)
#  end

#	def self.from_workspace(ws_id, order, limit)
#		req = "SELECT DISTINCT feed_items.* FROM feed_items "+
#			"LEFT JOIN items ON items.workspace_id = #{ws_id} AND items.itemable_type = 'FeedSource' "+
#			"LEFT JOIN feed_sources ON feed_sources.id = items.itemable_id "+
#			"WHERE feed_items.feed_source_id = feed_sources.id "+
#			"ORDER BY feed_items.#{order} LIMIT #{limit}"
#		req1 = "SELECT DISTINCT feed_items.* FROM feed_items, items, feed_sources "+
#				"WHERE items.workspace_id = #{ws_id} AND items.itemable_type = 'FeedSource' "+
#				"AND feed_sources.id IN (SELECT feed_source_id FROM  items.itemable_id AND feed_items.feed_source_id = feed_sources.id "+
#				"ORDER BY feed_items.#{order} LIMIT #{limit}"
#		res = FeedItem.find_by_sql(req)
#
#		#return FeedItem.find(:all, :conditions => { :feed_source =>  })
#	end

#	def self.consultable_by(user_id, order, limit)
#		req = "SELECT DISTINCT feed_items.* FROM feed_items "+
#			"INNER JOIN users_workspaces ON users_workspaces.user_id = #{user_id} "+
#			"INNER JOIN items ON items.workspace_id = users_workspaces.workspace_id AND items.itemable_type = 'FeedSource' "+
#			"INNER JOIN feed_sources ON (feed_sources.id = items.itemable_id OR feed_sources.user_id = #{user_id}) AND feed_items.feed_source_id = feed_sources.id "+
#			"ORDER BY feed_items.#{order} LIMIT #{limit}"
#		return FeedItem.find_by_sql(req)
#	end

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
    return { } if User.find(user_id).is_admin?
    { :select => 'feed_items.*',
      :joins => "LEFT JOIN items ON items.workspace_id = #{user_id} AND items.itemable_type = 'FeedSource' LEFT JOIN feed_sources ON feed_sources.id = items.itemable_id ",
      :conditions => "feed_items.feed_source_id = feed_sources.id"
    }
  }


end

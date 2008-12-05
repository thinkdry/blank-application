class GenericItem < ActiveRecord::Base
  self.inheritance_column = :item_type
  
  named_scope :images,
    :conditions => { :item_type => 'Image' }
  
  named_scope :videos,
    :conditions => { :item_type => 'Video' }
  
  named_scope :audios,
    :conditions => { :item_type => 'Audio' }
  
  named_scope :files,
    :conditions => { :item_type => 'CmsFile' }
    
  named_scope :cms_files,
    :conditions => { :item_type => 'CmsFile' }

  named_scope :articles,
    :conditions => { :item_type => 'Article' }
  
  named_scope :publications,
    :conditions => { :item_type => 'Publication' }
  
	named_scope :feed_sources,
    :conditions => { :item_type => 'FeedSource' }
	
	named_scope :bookmarks,
    :conditions => { :item_type => 'Bookmark' }
	
  named_scope :from_workspace, lambda { |ws_id|
    raise 'WS expected' unless ws_id
    { :select => 'generic_items.*',
      :joins => 'LEFT JOIN items ON generic_items.item_type = items.itemable_type AND generic_items.id = items.itemable_id',
      :conditions => "items.workspace_id = #{ws_id}"
    }
  }
  
  named_scope :consultable_by, lambda { |user_id|
    raise 'User expected' unless user_id
    return { } if User.find(user_id).is_admin?
    { :conditions => %{
        user_id = #{user_id} OR
        ( SELECT count(*)
          FROM items, users_workspaces
          WHERE
            items.itemable_type = generic_items.item_type AND
            items.itemable_id = generic_items.id AND
            users_workspaces.workspace_id = items.workspace_id AND
            users_workspaces.user_id = #{user_id} ) > 0 }}
  }
  
  named_scope :most_commented,
    :order => 'generic_items.number_of_comments DESC',
    :limit => 5
    
  named_scope :best_rated,
    :order => 'generic_items.average_rate DESC',
    :limit => 5
   
  named_scope :latest,
    :order => 'generic_items.created_at DESC',
    :limit => 5
	
end

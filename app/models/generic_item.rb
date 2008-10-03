class GenericItem < ActiveRecord::Base
  self.inheritance_column = :item_type
  
  named_scope :images,
    :conditions => { :item_type => 'Image' }
  
  named_scope :videos,
    :conditions => { :item_type => 'Video' }
  
  named_scope :audios,
    :conditions => { :item_type => 'Audio' }
  
  named_scope :files,
    :conditions => { :item_type => 'ArticFile' }

  named_scope :articles,
    :conditions => { :item_type => 'Article' }
  
  named_scope :publications,
    :conditions => { :item_type => 'Publication' }
  
  named_scope :from_workspace, lambda { |ws|
    raise 'WS expected' unless ws
    { :from => 'generic_items, items',
      :conditions => %{
        generic_items.item_type = items.itemable_type AND
        generic_items.id = items.itemable_id AND
        items.workspace_id = #{ws.id} }
    }
  }
  
  named_scope :consultable_by, lambda { |user|
    raise 'User expected' unless user
    { :conditions => %{
        user_id = #{user.id} OR
        ( SELECT count(*)
          FROM items, users_workspaces
          WHERE
            items.itemable_type = generic_items.item_type AND
            items.itemable_id = generic_items.id AND
            users_workspaces.workspace_id = items.workspace_id AND
            users_workspaces.user_id = #{user.id} ) > 0 }}
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

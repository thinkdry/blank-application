class GenericItem < ActiveRecord::Base
  self.inheritance_column = :item_type
    
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
    :order => 'number_of_comments DESC',
    :limit => 5
    
  named_scope :best_rated,
    :order => 'average_rate DESC',
    :limit => 5
   
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
end

class GenericItem < ActiveRecord::Base
  self.inheritance_column = :item_type
    
  named_scope :consultable, lambda { |user|
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
end

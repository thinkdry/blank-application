class AddIndexForTables < ActiveRecord::Migration
  def self.up
    add_index :users, :system_role_id
    ITEMS.each do |item|
      add_index item.pluralize.to_sym, :user_id
    end
    add_index :article_files, :article_id
    add_index :feed_items, :feed_source_id
    add_index :users_workspaces, :workspace_id
    add_index :users_workspaces, :user_id
    add_index :users_workspaces, :role_id
    add_index :roles, :name
    add_index :permissions, :name
    add_index :permissions_roles, :role_id
    add_index :permissions_roles, :permission_id
    add_index :items, :itemable_id
    add_index :items, :itemable_type
    add_index :comments, :user_id
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
    add_index :ratings, :user_id
    add_index :ratings, :rateable_id
    add_index :ratings, :rateable_type
    add_index :keywords, :user_id
    add_index :keywordings, :user_id
    add_index :keywordings, :keyword_id
    add_index :keywordings, :keywordable_id
    add_index :keywordings, :keywordable_type
    add_index :groups, :user_id
    add_index :groups, :workspace_id
    add_index :groupings, :group_id
    add_index :groupings, :user_id
    add_index :groupings, :contacts_workspace_id
    add_index :contacts_workspaces, :workspace_id
    add_index :contacts_workspaces, :contactable_id
    add_index :contacts_workspaces, :contactable_type
  end

  def self.down
  end
end

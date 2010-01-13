class AddIndexOnForeignKeys < ActiveRecord::Migration
  def self.up
    add_index :users_containers, :containerable_id
    add_index :users_containers, :containerable_type
    add_index :users_containers, :user_id
    add_index :users_containers, :role_id
    add_index :workspaces, :state
  end

  def self.down
  end
end

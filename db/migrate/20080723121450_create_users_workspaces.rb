class CreateUsersWorkspaces < ActiveRecord::Migration
  def self.up
    create_table :users_workspaces do |t|
      t.integer :workspace_id
      t.integer :role_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users_workspaces
  end
end

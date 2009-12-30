class CreateUsersContainers < ActiveRecord::Migration
  def self.up
    create_table :users_containers do |t|
      t.integer :containerable_id, :null => false
      t.string  :containerable_type, :null => false
      t.integer :role_id, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users_containers
  end
end

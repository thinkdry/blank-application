class CreateUsersWorkingSpaces < ActiveRecord::Migration
  def self.up
    create_table :users_working_spaces do |t|
      t.integer :working_space_id
      t.integer :role_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users_working_spaces
  end
end

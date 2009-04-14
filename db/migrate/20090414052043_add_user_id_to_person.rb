class AddUserIdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people,:user_id,:integer
    add_column :people, :newsletter, :boolean, :default => 0
  end

  def self.down
    remove_column :people,:user_id
    remove_column :people,:newsletter
  end
end

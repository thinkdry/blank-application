class AddCommentsNumberToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :comments_number, :integer, :default => 0
  end

  def self.down
    remove_column :groups, :comments_number
  end
end

class RemoveNewsletterColumn < ActiveRecord::Migration
  def self.up
    remove_column :people, :newsletter
    remove_column :users, :newsletter
  end

  def self.down
    add_column :people, :newsletter, :boolean
    add_column :users, :newsletter, :boolean
  end
end

class AddConfigColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :u_layout, :string
    add_column :users, :u_per_page, :integer
    add_column :users, :u_language, :string
  end

  def self.down
    remove_column :users, :u_layout
    remove_column :users, :u_per_page
    remove_column :users, :u_language
  end
end

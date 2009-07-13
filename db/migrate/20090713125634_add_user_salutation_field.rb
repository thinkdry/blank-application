class AddUserSalutationField < ActiveRecord::Migration
  def self.up
    add_column :users, :salutation, :string
  end

  def self.down
    remove_column :users, :salutation
  end
end

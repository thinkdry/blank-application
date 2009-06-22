class AddDateOfBirthAndGenderColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :date_of_birth, :date
    add_column :users, :gender, :string
  end

  def self.down
    remove_column :users, :date_of_birth
    remove_column :users, :gender
  end
end

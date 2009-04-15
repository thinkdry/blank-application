class AddDobColumnToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :salutation, :string
    add_column :people, :date_of_birth, :datetime
  end

  def self.down
    remove_column :people, :salutation
    remove_column :people, :date_of_birth
  end
end

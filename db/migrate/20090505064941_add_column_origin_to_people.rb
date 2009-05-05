class AddColumnOriginToPeople < ActiveRecord::Migration
  def self.up
    add_column :people,:origin,:string
  end

  def self.down
    remove_column :people,:origin
  end
end

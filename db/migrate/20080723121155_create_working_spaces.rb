class CreateWorkingSpaces < ActiveRecord::Migration
  def self.up
    create_table :working_spaces do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :working_spaces
  end
end

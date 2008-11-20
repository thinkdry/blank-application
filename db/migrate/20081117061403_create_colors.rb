class CreateColors < ActiveRecord::Migration
  def self.up
    create_table :colors do |t|
      t.integer:element_id
      t.string:bgcolor
      t.timestamps
    end
  end

  def self.down
    drop_table :colors
  end
end

class CreateRattings < ActiveRecord::Migration
  def self.up
    create_table :rattings do |t|
      t.integer :rate
      t.integer :user_id
      t.integer :rateable_id
      t.string  :rateable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :rattings
  end
end

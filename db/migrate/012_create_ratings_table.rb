class CreateRatingsTable < ActiveRecord::Migration

  def self.up
    create_table :ratings do |t|
      t.integer :rating
      t.integer :user_id
      t.integer :rateable_id
      t.string  :rateable_type
      t.timestamps
    end
    add_index :ratings, :user_id
    add_index :ratings, :rateable_id
    add_index :ratings, :rateable_type
  end

  def self.down
    drop_table :ratings
  end
end


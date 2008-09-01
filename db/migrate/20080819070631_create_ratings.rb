class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :rating
      t.integer :user_id
      t.integer :rateable_id
      t.string  :rateable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end

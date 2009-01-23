class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings, :id => false do |t|
      t.integer   :tag_id
			t.integer		:user_id
      t.integer   :taggable_id
      t.string    :taggable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :taggings
  end
end

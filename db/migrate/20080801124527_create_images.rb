class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
			t.integer :user_id
      t.string :title
      t.text :description
			t.string :state
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end

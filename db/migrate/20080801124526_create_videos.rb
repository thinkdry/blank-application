class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
			t.integer :user_id
      t.string :title
      t.text :description
			t.string :state, :default=>"initial"
      t.string :video_file_name
      t.string :video_content_type
      t.integer :video_file_size
      t.datetime :video_updated_at
			t.string :encoded_file
			t.string :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end

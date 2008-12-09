class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
			t.integer :user_id
      t.string :title
      t.text :description
			t.string :state
      t.string :file_path
			t.string :encoded_file
			t.string :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end

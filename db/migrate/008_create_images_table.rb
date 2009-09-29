class CreateImagesTable < ActiveRecord::Migration

  def self.up
    create_table :images do |t|
      t.integer  :user_id
      t.string   :title,              :limit => 255, :null => false
      t.text     :description,        :null => false
      t.string   :image_file_name,    :limit => 100
      t.string   :image_content_type, :limit => 20
      t.integer  :image_file_size
      t.datetime :image_updated_at
			t.string   :state,             :limit => 15
      t.integer  :viewed_number,     :default => 0
      t.integer  :comments_number,   :default => 0
      t.integer  :rates_average,     :default => 0
      t.timestamps
    end
    add_index :images, :user_id
  end

  def self.down
    drop_table :images
  end
end


class CreateBookmarksTable < ActiveRecord::Migration

  def self.up
    create_table :bookmarks do |t|
			t.integer  :user_id
			t.integer	 :feed_source_id
      t.string   :title,           :limit => 255, :null => false
			t.text     :description,     :null => false
			t.string	 :state,           :limit => 15
      t.string   :link,            :limit => 1024
			t.string	 :enclosures,      :limit => 255
			t.string	 :authors,         :limit => 255
			t.string	 :copyright,       :limit => 10
			t.string	 :categories,      :limit => 255
			t.integer  :viewed_number,   :default => 0
			t.integer  :comments_number, :default => 0
			t.integer  :rates_average,   :default => 0
			t.datetime :date_published
			t.datetime :last_updated
      t.timestamps
    end
    add_index :bookmarks, :user_id
    add_index :bookmarks, :feed_source_id
  end

  def self.down
    drop_table :bookmarks
  end
end


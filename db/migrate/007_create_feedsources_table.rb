class CreateFeedsourcesTable < ActiveRecord::Migration

  def self.up
    create_table  :feed_sources do |t|
      t.integer   :user_id
			t.string		:etag,             :limit => 255
			t.string		:version,          :limit => 20
			t.string		:encoding,         :limit => 20
			t.string		:language,         :limit => 50
      t.string    :title,            :limit => 255, :null => false
      t.text      :description ,     :null => false
			t.string		:state,            :limit => 10
      t.string    :url,             :limit => 1024
			t.string		:link,            :limit => 1024
			t.string		:authors,          :limit => 255
			t.string		:categories,       :limit => 255
			t.string		:copyright,        :limit => 10
			t.integer		:ttl,              :limit => 255
			t.string		:image,           :limit => 255
			t.integer   :viewed_number,   :default => 0
			t.integer   :comments_number, :default => 0
			t.integer   :rates_average,   :default => 0
			t.datetime	:last_updated
      t.timestamps
    end
    add_index :feed_sources, :user_id

    create_table :feed_items do |t|
      t.integer		:feed_source_id
			t.string		:guid,        :limit => 50
      t.string		:title,       :limit => 255
      t.text			:description
      t.string		:authors,     :limit => 255
			t.string		:enclosures,  :limit => 255
      t.string		:link,        :limit => 1024
			t.string		:categories,  :limit => 255
			t.string		:copyright,   :limit => 10
			t.datetime	:date_published
			t.datetime	:last_updated
      t.timestamps
    end
    add_index :feed_items, :feed_source_id
  end

  def self.down
    drop_table :feed_sources
    drop_table :feed_items
  end
end


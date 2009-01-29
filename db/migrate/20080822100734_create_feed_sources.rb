class CreateFeedSources < ActiveRecord::Migration
  def self.up
    create_table  :feed_sources do |t|
      t.integer   :user_id
			t.string		:etag
			t.string		:version
			t.string		:encoding
			t.string		:language
      t.string    :title
      t.text      :description
			t.string		:state
      t.string    :url, :limit => 1024
			t.string		:link, :limit => 1024
			t.datetime	:last_updated
			t.string		:authors
			t.string		:categories
			t.string		:copyright
			t.integer		:ttl
			t.string		:image
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_sources
  end
end

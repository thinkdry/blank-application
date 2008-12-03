class CreateFeedSources < ActiveRecord::Migration
  def self.up
    create_table  :feed_sources do |t|
      t.integer   :user_id
			t.string		:remote_id
      t.string    :title
      t.text      :description
			t.string		:state
      t.string    :url, :limit => 1024
			t.string		:link, :limit => 1024
			t.datetime	:last_updated
			t.string		:authors
			t.string		:copyright
			t.string		:generator
			t.integer		:ttl
			t.string		:image_path
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_sources
  end
end

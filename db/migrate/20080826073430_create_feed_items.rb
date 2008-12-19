class CreateFeedItems < ActiveRecord::Migration
	
  def self.up
    create_table :feed_items do |t|
      t.integer		:feed_source_id
			t.string		:guid
      t.string		:title
      t.text			:description
      t.string		:authors
			t.datetime	:date_published
			t.datetime	:last_updated
			t.string		:enclosures
      t.string		:link, :limit => 1024
			t.string		:categories
			t.string		:copyright
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_items
  end
end

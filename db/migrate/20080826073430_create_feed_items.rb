class CreateFeedItems < ActiveRecord::Migration
	
  def self.up
    create_table :feed_items do |t|
      t.string  :remote_id
      t.integer :feed_source_id
      t.string  :title
			t.string	:content
      t.text    :description
      t.string  :authors
			t.datetime	:date_published
      t.string  :link
			t.string	:categories
			t.string	:copyright
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_items
  end
end

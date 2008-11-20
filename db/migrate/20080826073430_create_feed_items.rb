class CreateFeedItems < ActiveRecord::Migration
  def self.up
    create_table :feed_items do |t|
      t.string  :guid
      t.integer :feed_source_id
      t.string  :title
      t.text    :description
      t.string  :author
      t.string  :link
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_items
  end
end

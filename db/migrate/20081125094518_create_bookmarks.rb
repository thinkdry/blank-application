class CreateBookmarks < ActiveRecord::Migration
	
  def self.up
    create_table :bookmarks do |t|
			t.integer :user_id
			t.integer	:feed_source_id
      t.string  :title
			t.text    :description
			t.string	:state
      t.string  :link => 1024
			t.string	:content
			t.string	:authors
			t.datetime :date_published
			t.datetime :last_updated
			t.string	:copyright
			t.string	:categories
      t.timestamps
    end
  end

  def self.down
    drop_table :bookmarks
  end
end

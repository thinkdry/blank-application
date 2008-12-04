class CreatePublications < ActiveRecord::Migration
  
  def self.up
    create_table :publications do |t|
      t.integer :user_id
      t.string  :title
			t.text    :description
			t.string	:state
      t.string  :link
			t.string	:content
			t.string	:authors
			t.datetime :date_published
			t.datetime :last_updated
			t.string	:copyright
			t.string	:categories
			t.string	:file_path
      t.timestamps
    end
  end

  def self.down
    drop_table :publications
  end
end

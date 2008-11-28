class CreateLinks < ActiveRecord::Migration
	
  def self.up
    create_table :links do |t|
			t.integer :user_id
      t.string  :title
      t.string  :link
			t.string	:content
      t.text    :description
			t.string	:authors
			t.datetime :date_published
			t.string	:copyright
			t.string	:categories
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end

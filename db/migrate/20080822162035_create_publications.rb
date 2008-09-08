class CreatePublications < ActiveRecord::Migration
  def self.up
    create_table :publications do |t|
      t.integer :user_id
      t.boolean :imported
      t.string  :title
      t.string  :author
      t.string  :link
      t.text    :description
      t.string  :file_path
      t.boolean :private, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :publications
  end
end

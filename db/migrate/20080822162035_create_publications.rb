class CreatePublications < ActiveRecord::Migration
  def self.up
    create_table :publications do |t|
      t.string  :title
      t.string  :author
      t.date    :publication_date
      t.string  :url
      t.text    :description
      t.string  :file_path
      t.timestamps
    end
  end

  def self.down
    drop_table :publications
  end
end

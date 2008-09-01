class CreatePubmedItems < ActiveRecord::Migration
  def self.up
    create_table :pubmed_items do |t|
      t.string  :guid
      t.integer :pubmed_source_id
      t.string  :title
      t.text    :description
      t.string  :author
      t.string  :link
      t.timestamps
    end
  end

  def self.down
    drop_table :pubmed_items
  end
end

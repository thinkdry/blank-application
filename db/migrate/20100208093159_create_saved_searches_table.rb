class CreateSavedSearchesTable < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.string   :title
      t.string   :description
      t.string   :q
      t.string   :field
      t.string   :order
      t.text     :containers
      t.string   :items
      t.integer  :limit
      t.datetime :created_at_after
      t.datetime :created_at_before
      t.integer  :user_id
      t.timestamps
    end
    add_index :saved_searches, :user_id
  end

  def self.down
    drop_table :saved_searches
  end
end

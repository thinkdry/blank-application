class CreateResultset < ActiveRecord::Migration
 def self.up
    drop_table :saved_searches

    create_table :result_sets do |t|
      t.integer  :user_id
      t.string   :title,           :limit => 255, :null => false
      t.text     :description,     :null => false
			t.string   :state,           :limit => 15
      t.integer  :viewed_number,   :default => 0
      t.integer  :comments_number, :default => 0
      t.integer  :rates_average,   :default => 0
      t.boolean  :published,       :default => false
      t.string   :title_sanitized
      t.string   :page_title
      t.string   :q
      t.string   :field
      t.string   :order
      t.text     :containers
      t.string   :items
      t.integer  :limit
      t.datetime :created_at_after
      t.datetime :created_at_before
      t.timestamps
    end
    add_index :result_sets, :user_id
  end

  def self.down
    drop_table :result_sets
  end
end

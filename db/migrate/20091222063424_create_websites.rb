class CreateWebsites < ActiveRecord::Migration
  def self.up
    create_table :websites do |t|
      t.integer :creator_id
      t.string  :title,              :limit => 255, :null => false
      t.text    :description,                       :null => false
      t.string  :state,              :limit => 15
      t.string  :available_items,           :limit => 255
      t.string  :logo_file_name,     :limit => 100
      t.string  :logo_content_type,  :limit => 50
      t.integer :logo_file_size
      t.string  :available_types, :limit => 255
      t.timestamps
    end

    create_table :items_websites do |t|
      t.integer :website_id, :null => false
      t.integer :itemable_id, :null => false
      t.string  :itemable_type, :null => false
      t.timestamps
    end
   
    add_index :websites, :creator_id
    add_index :items_websites, :website_id
    add_index :items_websites, :itemable_id
    add_index :items_websites, :itemable_type
  end

  def self.down
    drop_table :workspaces
    drop_table :items_workspaces
  end
end

class CreateWorkspacesTable < ActiveRecord::Migration

  def self.up
    create_table :workspaces do |t|
      t.integer :creator_id
      t.string  :title,              :limit => 255, :null => false
      t.text    :description,                       :null => false
      t.string  :state,              :limit => 15
      t.string  :available_items,   :limit => 255
      t.string  :logo_file_name,    :limit => 100
      t.string  :logo_content_type, :limit => 50
      t.integer :logo_file_size
      t.string  :available_types,   :limit => 255
      t.timestamps
    end

    create_table :items_workspaces do |t|
      t.integer :workspace_id, :null => false
      t.integer :itemable_id, :null => false
      t.string  :itemable_type, :null => false
      t.timestamps
    end
   

    create_table :contacts_workspaces do |t|
      t.integer :workspace_id
      t.integer :contactable_id
      t.string  :contactable_type, :limit => 50
      t.string  :state,            :limit => 15
      t.string  :sha1_id,          :limit => 40
      t.timestamps
    end
    
    add_index :workspaces, :creator_id
    add_index :items_workspaces, :workspace_id
    add_index :items_workspaces, :itemable_id
    add_index :items_workspaces, :itemable_type
    add_index :contacts_workspaces, :workspace_id
    add_index :contacts_workspaces, :contactable_id
    add_index :contacts_workspaces, :contactable_type
  end

  def self.down
    drop_table :workspaces
    drop_table :items_workspaces
    drop_table :contacts_workspaces
  end
end


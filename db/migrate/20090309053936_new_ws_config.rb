class NewWsConfig < ActiveRecord::Migration
  def self.up
		add_column :workspaces, :ws_items, :string
		add_column :workspaces, :ws_item_categories, :string
		add_column :workspaces, :logo_file_name, :string
    add_column :workspaces, :logo_content_type, :string
    add_column :workspaces, :logo_file_size, :integer
  end

  def self.down
  end
end

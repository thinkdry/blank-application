class NewColumns < ActiveRecord::Migration
  def self.up
		change_column_default :workspaces, :ws_items, ""
		change_column_default :workspaces, :ws_item_categories, ""
		add_column :workspaces, :ws_available_types, :string, :default => ""
  end

  def self.down
  end
end

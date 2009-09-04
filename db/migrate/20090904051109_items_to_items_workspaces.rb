class ItemsToItemsWorkspaces < ActiveRecord::Migration
  def self.up
    rename_table :items, :items_workspaces
  end

  def self.down
		rename_table :items_workspaces, :items
  end
end

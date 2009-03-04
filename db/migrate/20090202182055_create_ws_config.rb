class CreateWsConfig < ActiveRecord::Migration
  def self.up
    create_table :ws_configs do |t|
			t.string :ws_items
			t.string :ws_feed_items_importation_types
      t.timestamps
    end
		add_column :workspaces, :ws_config_id, :integer
  end

  def self.down
    drop_table :ws_configs
		remove_column :workspaces, :ws_config_id
  end
end

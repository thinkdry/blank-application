class CreateWsConfig < ActiveRecord::Migration
  def self.up
    create_table :ws_configs do |t|
			t.string :ws_items
			t.string :ws_feed_items_importation_types
      t.timestamps
    end
		add_column :workspaces, :ws_config_id, :integer
    if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
			conf = YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
		else
			conf = YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
		end
		default_conf = WsConfig.new(:id => 1, :ws_items => conf["sa_items"].join(","), :ws_feed_items_importation_types => conf["sa_feed_items_importation_types"].join(","))
		default_conf.save
  end

  def self.down
    drop_table :ws_configs
		remove_column :workspaces, :ws_config_id
  end
end

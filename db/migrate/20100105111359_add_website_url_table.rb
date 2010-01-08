class AddWebsiteUrlTable < ActiveRecord::Migration
  def self.up
    create_table :website_urls do |t|
      t.string :name
      t.integer :website_id
    end
  end

  def self.down
    drop_table :website_urls
  end
end

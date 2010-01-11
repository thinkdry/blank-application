class CreateMenusTable < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.string  :name
      t.string  :url
      t.string  :parent_id
      t.integer :website_id
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end

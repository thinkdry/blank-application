class AddLinkOnToMenuTree < ActiveRecord::Migration
  def self.up
    add_column :menus, :link_on, :string, :default => "menu"
  end

  def self.down
    remove_column :menus, :link_on
  end
end

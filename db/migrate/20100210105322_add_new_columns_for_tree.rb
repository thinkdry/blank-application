class AddNewColumnsForTree < ActiveRecord::Migration
  def self.up
    add_column :menus, :title_sanitized, :string
    add_column :menus, :page_title, :string
    add_column :menus, :page_id, :integer
    add_column :menus, :result_set_id, :integer
  end

  def self.down
    remove_column :menus, :title_sanitized
    remove_column :menus, :page_title
    remove_column :menus, :page_id
    remove_column :menus, :result_set_id
  end
end

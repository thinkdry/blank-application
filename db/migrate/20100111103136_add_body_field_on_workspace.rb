class AddBodyFieldOnWorkspace < ActiveRecord::Migration
  def self.up
    change_column :websites,   :description, :string
    change_column :folders,    :description, :string
    change_column :workspaces, :description, :string
    add_column    :workspaces, :body, :text
  end

  def self.down
    change_column :websites,   :description, :text
    change_column :folders,    :description, :text
    change_column :workspaces, :description, :text
    drop_column :workspaces, :body
  end
end

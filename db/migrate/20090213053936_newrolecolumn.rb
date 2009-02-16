class Newrolecolumn < ActiveRecord::Migration
  def self.up
    add_column :permissions, :type_permission, :string
    add_column :roles, :type_role, :string
  end

  def self.down
  end
end

class CreatePermissionsRolesTable < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
			t.text   :description
			t.string :type_role
      t.timestamps
    end
    add_index :roles, :name

		create_table :permissions do |t|
			t.string :name
			t.text   :description
			t.string :type_permission
      t.timestamps
		end
		add_index :permissions, :name

		create_table :permissions_roles, :id => false do |t|
			t.integer :permission_id
			t.integer :role_id
		end
    add_index :permissions_roles, :permission_id
    add_index :permissions_roles, :role_id
  end

  def self.down
    drop_table :roles
    drop_table :permissions
    drop_table :permissions_roles
  end
end


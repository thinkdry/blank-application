class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
			t.text :description
      t.timestamps
    end
  
		create_table :permissions do |t|
			t.string :name
			t.text :description
      t.timestamps
		end

		create_table :permissions_roles, :id => false do |t|
			t.integer :permission_id
			t.integer :role_id
		end
	
	end



  def self.down
    drop_table :roles
  end
end

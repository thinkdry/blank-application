class CreateSystemRoles < ActiveRecord::Migration
  def self.up
    create_table :system_roles do |t|
      t.string  :name
      t.timestamps
    end
    SystemRole.create(:name => 'admin')
    SystemRole.create(:name => 'superadmin')
  end

  def self.down
    drop_table :system_roles
  end
end

class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
			t.text :description
      t.timestamps
    end
    Role.create(:name => 'moderator')
    Role.create(:name => 'writer')
    Role.create(:name => 'reader')
  end

  def self.down
    drop_table :roles
  end
end

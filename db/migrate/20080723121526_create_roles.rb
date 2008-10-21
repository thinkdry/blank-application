class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.timestamps
    end
    Role.create(:name => 'Modérateur')
    Role.create(:name => 'Rédacteur')
    Role.create(:name => 'Lecteur')
  end

  def self.down
    drop_table :roles
  end
end

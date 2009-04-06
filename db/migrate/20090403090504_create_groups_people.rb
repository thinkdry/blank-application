class CreateGroupsPeople < ActiveRecord::Migration
  def self.up
    create_table :groups_people do |t|
      t.integer :group_id
      t.integer :person_id
      t.timestamps
    end
  end

  def self.down
    drop_table :groups_people
  end
end

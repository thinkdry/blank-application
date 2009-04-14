class CreateGroupings < ActiveRecord::Migration
  def self.up
    
    drop_table :groups_people
    
    create_table :groupings,:id=>false do |t|
      t.integer :group_id
      t.integer :groupable_id
      t.string :groupable_type
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :groupings
  end
end

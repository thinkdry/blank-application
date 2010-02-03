class CreateDataPeople < ActiveRecord::Migration
  def self.up
    create_table :data_people, :force => true do |t|
      t.integer :person_id
      t.integer :workspace_id
      t.string :origin
      t.string :type_data
      t.text :data
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :data_people
  end
end

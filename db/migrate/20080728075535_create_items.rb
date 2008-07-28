class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :itemable_type
      t.integer :itemable_id
      t.integer :workspace_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end

class CreateWorkspaces < ActiveRecord::Migration
  def self.up
    create_table :workspaces do |t|
			t.integer :creator_id
			t.text :description
      t.string :title
			t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :workspaces
  end
end

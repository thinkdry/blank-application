class CreateWorkspaces < ActiveRecord::Migration
  def self.up
    create_table :workspaces do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :workspaces
  end
end

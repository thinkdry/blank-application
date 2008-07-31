class CreateArticFiles < ActiveRecord::Migration
  def self.up
    create_table :artic_files do |t|
      t.string :title
      t.text :description
      t.string :file_path
			t.boolean :private, :default => false
			
      t.timestamps
    end
  end

  def self.down
    drop_table :artic_files
  end
end

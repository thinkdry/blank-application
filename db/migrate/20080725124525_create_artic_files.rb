class CreateArticFiles < ActiveRecord::Migration
  def self.up
    create_table :artic_files do |t|
      t.string :title
      t.text :description
      t.string :file_type, :default => nil
      t.string :file_path
			t.string :state, :default => nil
			
      t.timestamps
    end
  end

  def self.down
    drop_table :artic_files
  end
end

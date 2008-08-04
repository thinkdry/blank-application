class CreateAudios < ActiveRecord::Migration
  def self.up
    create_table :audios do |t|
      t.string :title
      t.text :description
      t.string :file_path
			t.boolean :private, :default => false
			
      t.timestamps
    end
  end

  def self.down
    drop_table :audios
  end
end

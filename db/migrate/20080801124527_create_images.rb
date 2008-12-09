class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
			t.integer :user_id
      t.string :title
      t.text :description
			t.string :state
      t.string :file_path
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end

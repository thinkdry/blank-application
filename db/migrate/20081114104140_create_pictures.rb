class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :name
      t.string :picture_file_name
			t.string :picture_content_type
			t.integer :picture_file_size
			t.datetime :picture_updated_at
      t.timestamps
    end
     Picture.create(:name => 'logo')
  end

  def self.down
    drop_table :pictures
  end
end

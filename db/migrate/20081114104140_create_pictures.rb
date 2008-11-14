class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :name
      t.string :picture_path
      t.timestamps
			
    end
		Picture.create(:name => 'logo')
  end

  def self.down
    drop_table :pictures
  end
end

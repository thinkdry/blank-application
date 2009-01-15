class CreateCmsFiles < ActiveRecord::Migration
  def self.up
    create_table :cms_files do |t|
			t.integer :user_id
      t.string :title
      t.text :description
      t.string :state
      t.string :cmsfile_file_name
      t.string :cmsfile_content_type
      t.integer :cmsfile_file_size
      t.datetime :cmsfile_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :cms_files
  end
end

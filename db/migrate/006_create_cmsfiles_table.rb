class CreateCmsfilesTable < ActiveRecord::Migration

  def self.up
    create_table :cms_files do |t|
      t.integer  :user_id
      t.string   :title,               :limit => 255, :null => false
      t.text     :description,         :null => false
      t.string   :cmsfile_file_name,    :limit => 100
      t.string   :cmsfile_content_type, :limit => 20
      t.integer  :cmsfile_file_size
      t.datetime :cmsfile_updated_at
			t.string   :state,               :limit => 15
      t.integer  :viewed_number,       :default => 0
      t.integer  :comments_number,     :default => 0
      t.integer  :rates_average,       :default => 0
      t.timestamps
    end
    add_index :cms_files, :user_id
  end

  def self.down
    drop_table :cms_files
  end
end


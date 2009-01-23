class CreateArticleFiles < ActiveRecord::Migration
  def self.up
    create_table :article_files do |t|
      t.integer :article_id
      t.string :articlefile_file_name
      t.string :articlefile_content_type
      t.integer :articlefile_file_size
      t.datetime :articlefile_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :article_files
  end
end

class CreateArticleFiles < ActiveRecord::Migration
  def self.up
    create_table :article_files do |t|
      t.integer :article_id
      t.string :file_path
      t.timestamps
    end
  end

  def self.down
    drop_table :article_files
  end
end

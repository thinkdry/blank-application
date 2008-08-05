class CreateArticleImages < ActiveRecord::Migration
  def self.up
    create_table :article_images do |t|
      t.integer :article_id
      t.string :image_path

      t.timestamps
    end
  end

  def self.down
    drop_table :article_images
  end
end

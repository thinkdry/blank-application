class CreateArticlesTable < ActiveRecord::Migration

  def self.up
    create_table :articles do |t|
      t.integer :user_id
      t.string  :title,           :limit => 255, :null => false
      t.text    :description,     :null => false
			t.string  :state,           :limit => 15
      t.text    :body
      t.integer :viewed_number,   :default => 0
      t.integer :comments_number, :default => 0
      t.integer :rates_average,   :default => 0
      t.timestamps
    end
    add_index :articles, :user_id

    create_table :article_files do |t|
      t.integer  :article_id
      t.string   :articlefile_file_name,    :limit => 100
      t.string   :articlefile_content_type, :limit => 20
      t.integer  :articlefile_file_size
      t.datetime :articlefile_updated_at
      t.timestamps
    end
    add_index :article_files, :article_id

  end

  def self.down
    drop_table :articles
    drop_table :article_files
  end

end


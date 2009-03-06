class AddColumns < ActiveRecord::Migration
  def self.up
    add_column :articles, :viewed_number, :integer
    add_column :articles, :rates_average, :integer
		add_column :articles, :comments_number, :integer
		add_column :articles, :category, :string
		add_column :audios, :viewed_number, :integer
    add_column :audios, :rates_average, :integer
		add_column :audios, :comments_number, :integer
		add_column :audios, :category, :string
		add_column :bookmarks, :viewed_number, :integer
    add_column :bookmarks, :rates_average, :integer
		add_column :bookmarks, :comments_number, :integer
		add_column :bookmarks, :category, :string
		add_column :cms_files, :viewed_number, :integer
    add_column :cms_files, :rates_average, :integer
		add_column :cms_files, :comments_number, :integer
		add_column :cms_files, :category, :string
		add_column :feed_sources, :viewed_number, :integer
    add_column :feed_sources, :rates_average, :integer
		add_column :feed_sources, :comments_number, :integer
		add_column :feed_sources, :category, :string
		add_column :images, :viewed_number, :integer
    add_column :images, :rates_average, :integer
		add_column :images, :comments_number, :integer
		add_column :images, :category, :string
		add_column :publications, :viewed_number, :integer
    add_column :publications, :rates_average, :integer
		add_column :publications, :comments_number, :integer
		add_column :publications, :category, :string
		add_column :videos, :viewed_number, :integer
    add_column :videos, :rates_average, :integer
		add_column :videos, :comments_number, :integer
		add_column :videos, :category, :string

		add_column :users, :newsletter, :boolean
  end

  def self.down
  end
end

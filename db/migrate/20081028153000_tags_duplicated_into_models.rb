class TagsDuplicatedIntoModels < ActiveRecord::Migration
  def self.up
    add_column :articles,     :tags,  :string
    add_column :cms_files,		:tags,  :string
    add_column :audios,       :tags,  :string
    add_column :images,       :tags,  :string
    add_column :publications, :tags,  :string
    add_column :videos,       :tags,  :string
  end

  def self.down
    remove_column :articles,     :tags
    remove_column :cms_files,		 :tags
    remove_column :audios,       :tags
    remove_column :images,       :tags
    remove_column :publications, :tags
    remove_column :videos,       :tags
  end
end

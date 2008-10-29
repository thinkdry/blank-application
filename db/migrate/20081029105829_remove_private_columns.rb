class RemovePrivateColumns < ActiveRecord::Migration
  def self.up
    remove_column :articles,     :private
    remove_column :artic_files,  :private
    remove_column :audios,       :private
    remove_column :images,       :private
    remove_column :publications, :private
    remove_column :videos,       :private
  end

  def self.down
    add_column :articles,     :private,  :boolean, :default => false
    add_column :artic_files,  :private,  :boolean, :default => false
    add_column :audios,       :private,  :boolean, :default => false
    add_column :images,       :private,  :boolean, :default => false
    add_column :publications, :private,  :boolean, :default => false
    add_column :videos,       :private,  :boolean, :default => false
  end
end

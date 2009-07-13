class CleanAllUnusedField < ActiveRecord::Migration
  def self.up
    remove_column :queued_mails, :user_id
    remove_column :queued_mails, :url
    (ITEMS - ['feed_source','bookmark']).each do |item|
      remove_column item.pluralize.to_sym, :tags
      remove_column item.pluralize.to_sym, :category
    end
    remove_column :bookmarks, :category
    remove_column :feed_sources, :category
  end

  def self.down
  end
end

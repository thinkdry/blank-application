class CleanAllUnusedField < ActiveRecord::Migration
  def self.up
    remove_column :queued_mails, :user_id
    remove_column :queued_mails, :url
    (ITEMS - ['feed_source','bookmark', 'page']).each do |item|
      remove_column item.pluralize.to_sym, :tags
      remove_column item.pluralize.to_sym, :category
    end
    remove_column :bookmarks, :category
    remove_column :feed_sources, :category
		if ITEMS.include?('page')
			remove_column :pages, :category
		end
  end

  def self.down
  end
end

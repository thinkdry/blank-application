class ChangeDefaultItemStateToUnpublished < ActiveRecord::Migration
  def self.up
    ITEMS.each do |item|
      add_column item.pluralize.to_sym, :published, :boolean, :default => false
    end
  end

  def self.down
    ITEMS.each do |item|
      remove_column item.pluralize.to_sym
    end
  end
end

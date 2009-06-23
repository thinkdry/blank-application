class DefaultValuesInItems < ActiveRecord::Migration
  def self.up
    ITEMS.each do |item|
			change_column_default item.pluralize.to_sym, :viewed_number, 0
			change_column_default item.pluralize.to_sym, :comments_number, 0
			change_column_default item.pluralize.to_sym, :rates_average, 0
		end
  end

  def self.down
    
  end
end

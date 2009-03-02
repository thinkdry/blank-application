# == Schema Information
# Schema version: 20181126085723
#
# Table name: searches
#
#  item_type_equals     :string
#  title_contains       :string
#  description_contains :string
#  user_name_contains   :string
#  created_after        :datetime
#  created_before       :datetime
#

class Search < ActiveRecord::Base
  # Tableless model
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

	column :full_text_field, :string
	column :category, :string
	# Just for Items
	column :item_types, :string
	# Just for Workspaces
	# column :workspace_types, :string
	# Just for Items and Workpaces
  column :creator, :string
	# For all
  column :created_after, :datetime
  column :created_before, :datetime
  
  validates_date :created_after, :created_before, :allow_nil => true
end

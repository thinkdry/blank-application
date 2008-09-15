class Search < ActiveRecord::Base
  # Tableless model
  def self.columns() @columns ||= []; end
 
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
 
  column :item_type_equals, :string
  column :title_contains, :integer
  column :description_contains, :string
  column :created_after, :datetimne
  column :created_before, :datetime
  
  validates_date :created_after, :created_before, :allow_nil => true
end
class Publication < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :author, :file_path]
  
  file_column :file_path
  
  validates_presence_of :author
  
  def self.label
    "Publication"
  end
end

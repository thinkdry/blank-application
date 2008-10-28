class Image < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :file_path]
  
  file_column :file_path, :magick => { :versions => { :thumb => "100x100", :web => "500x500" } }
  
  validates_presence_of :file_path
  validates_file_format_of :file_path, :in => ["png", "gif", "jpg"]
  
  def self.label
    "Image"
  end
end

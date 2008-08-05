class Image < ActiveRecord::Base
	
  acts_as_item
  
	belongs_to :user
	
	file_column :file_path, :magick => { :versions => { :thumb => "100x100", :web => "500x500" } }
	
	validates_presence_of	:title,
		:description,
		:file_path,
		:user
	
	#validates_file_format_of :file_path, :in => ["gif", "png", "jpg"]
	
end

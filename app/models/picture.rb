class Picture < ActiveRecord::Base
	
	file_column :picture_path, :magick => { :versions => { :favicon => "16x16", :thumb => "168x80", :normal => "400x80" } }
  
  validates_presence_of :picture_path
  validates_file_format_of :picture_path, :in => ["png", "gif", "jpg"]
	
end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: pictures
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  picture_path :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Picture < ActiveRecord::Base
	
	file_column :picture_path, :magick => { :versions => { :favicon => "16x16", :thumb => "168x80", :normal => "400x80" } }
  
  #validates_presence_of :picture_path, :allow_blank => true
  validates_file_format_of :picture_path, :in => ["png", "gif", "jpg"]
	
end

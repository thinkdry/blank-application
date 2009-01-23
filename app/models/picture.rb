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
	
	#file_column :picture_path, :magick => { :versions => { :favicon => "16x16", :thumb => "168x80", :normal => "400x80" } }
  has_attached_file :picture,
                                   :url =>    "/uploaded_files/picture/:id/:style/:basename.:extension",
                                   :path => ":rails_root/public/uploaded_files/picture/:id/:style/:basename.:extension",
                                   :styles => { :medium => "480x80>",
                                   :thumb => "16x16>" }
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates_attachment_size(:image, :less_than => 2.megabytes)
  #validates_presence_of :picture_path, :allow_blank => true
  #validates_file_format_of :picture_path, :in => ["png", "gif", "jpg"]
	
end

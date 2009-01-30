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
                    :default_url => "/images/logo.png",
                    :url =>    "/uploaded_files/picture/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/picture/:id/:style/:basename.:extension",
                    :styles => { :large => "480x80>",
                    :medium=>"240x40>",
                    :thumb => "16x16>" }
                                                   
  has_attached_file :favicon,
                    :default_url => "/images/favicon.ico",
                    :url =>    "/uploaded_files/favicon/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/favicon/:id/:style/:basename.:extension",
                    :styles => { :medium=>"120x20>",
                    :thumb => "16x16>" }
  #validates_attachment_presence :picture
  #validates_attachment_content_type :picture, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  #validates_attachment_size(:picture, :less_than => 2.megabytes)
  #validates_presence_of :picture_path, :allow_blank => true
  #validates_file_format_of :picture_path, :in => ["png", "gif", "jpg"]
	
end

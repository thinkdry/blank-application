# == Schema Information
# Schema version: 20181126085723
#
# Table name: images
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  title       :string(255)
#  description :text
#  state       :string(255)
#  file_path   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  tags        :string(255)
#

class Image < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :image_file_name]
  has_attached_file :image,
                                   :styles => { :medium => "300x300>",
                                   :thumb => "100x100>" }
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates_attachment_size(:image, :less_than => 1.megabytes)
  #file_column :file_path, :magick => { :versions => { :thumb => "100x100", :web => "500x500" } }
 # validates_presence_of :file_path
 #  validates_file_format_of :file_path, :in => ["png", "gif", "jpg"]
 
end

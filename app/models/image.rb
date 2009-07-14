# == Schema Information
# Schema version: 20181126085723
#
# Table name: images
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  viewed_number      :integer(4)      default(0)
#  rates_average      :integer(4)      default(0)
#  comments_number    :integer(4)      default(0)
#

class Image < ActiveRecord::Base

  # Item specific Library - /lib/acts_as_item
  acts_as_item

  # Paperclip Attachment 
  has_attached_file :image,
    :url =>    "/uploaded_files/image/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/image/:id/:style/:basename.:extension",
    :styles => { :medium => "300x300>", :thumb => "48x48>" }

  # Paperclip Validation
  validates_attachment_presence :image

  validates_attachment_content_type :image, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']

  validates_attachment_size(:image, :less_than => 25.megabytes)

  # Media Type for the Model.
  #
  # Usage:
  #
  # <tt>object.media_type</tt>
  #
  # will return the media type as image
  def media_type
    image
  end
 
end

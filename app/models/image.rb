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

# This class is defining an item object called 'Image'.
#
# You can use it to upload an image in the Blank application,
# according to the file types available and the size of the file.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Image < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item
  # Paperclip attachment definition
  has_attached_file :image,
    :url =>    "/uploaded_files/image/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/image/:id/:style/:basename.:extension",
    :styles => { :medium => "300x300>", :thumb => "48x48>" }
  # Validation of the presence of an attached file
  validates_attachment_presence :image
	# Validation of the type of the attached file
  validates_attachment_content_type :image, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp', 'image/x-png', 'image/pjpeg']
	# Validation of the size of the attached file
  validates_attachment_size(:image, :less_than => 25.megabytes)

  # Media Type for the object
	#
	# No actual use but consistency with other media type (Video, Audio).
  #
  # Usage:
  # <tt>object.media_type</tt>
  def media_type
    image
  end
 
end

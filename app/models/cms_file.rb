# == Schema Information
# Schema version: 20181126085723
#
# Table name: cms_files
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  title                :string(255)
#  description          :text
#  state                :string(255)
#  cmsfile_file_name    :string(255)
#  cmsfile_content_type :string(255)
#  cmsfile_file_size    :integer(4)
#  cmsfile_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  viewed_number        :integer(4)      default(0)
#  rates_average        :integer(4)      default(0)
#  comments_number      :integer(4)      default(0)
#

# This class is defining an item object called 'CmsFile'.
#
# You can use it to add a file, according the different types allowed and respecting the maximum size.
#
# On the show page, a link allowing to download that file is set.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class CmsFile < ActiveRecord::Base

	# Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item

	# Audit activation of the item
	acts_as_audited :except => :viewed_number

	# Paperclip attachment definition
  has_attached_file :cmsfile,
    :url =>    "/uploaded_files/cmsfile/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/cmsfile/:id/:style/:basename.:extension"
  # Validation of the presence of an attached file
  validates_attachment_presence :cmsfile
	# Validation of the type of the attached file
  #	validates_attachment_content_type :cmsfile, :content_type => ['application/pdf', 'text/plain','application/octet-stream','application/msword', 'application/rtf']
	# Validation of the size of the attached file
  validates_attachment_size(:cmsfile, :less_than => 25.megabytes)

end

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

class CmsFile < ActiveRecord::Base

  acts_as_item

  has_attached_file :cmsfile,
    :url =>    "/uploaded_files/cmsfile/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/cmsfile/:id/:style/:basename.:extension"
  
  validates_attachment_presence :cmsfile
  
  # TODO Need to find proper content-types sent by different browsers, currently validation managed through javascript
  #	validates_attachment_content_type :cmsfile, :content_type => ['application/pdf', 'text/plain','application/octet-stream','application/msword', 'application/rtf']

  validates_attachment_size(:cmsfile, :less_than => 25.megabytes)

end

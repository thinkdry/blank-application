# == Schema Information
# Schema version: 20181126085723
#
# Table name: cms_files
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  title       :string(255)
#  description :text
#  file_path   :string(255)
#  state       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  tags        :string(255)
#

class CmsFile < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :cmsfile_file_name]
  has_attached_file :cmsfile,
                                    :url =>    "/uploaded_files/cmsfile/:id/:style/:basename.:extension",
                                   :path => ":rails_root/public/uploaded_files/cmsfile/:id/:style/:basename.:extension"
  validates_attachment_presence :cmsfile
  validates_attachment_content_type :cmsfile, :content_type => ['application/pdf', 'text/plain','application/octet-stream','application/msword']
  validates_attachment_size(:cmsfile, :less_than => 5.megabytes)
  #file_column :file_path
   # validates_presence_of :file_path
  
  def self.label
    "Fichier"
  end
end

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
#  tags                 :string(255)
#

class CmsFile < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :cmsfile_file_name, :cmsfile_content_type],
                 :values => [[:created_at, 0, "created_at", :number], [:title, 1, "title", :string], [:comment_size, 2, "comment_size", :number], [:rate_size, 3, "rate_size", :number]]
  has_attached_file :cmsfile,
    :url =>    "/uploaded_files/cmsfile/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/cmsfile/:id/:style/:basename.:extension"
  validates_attachment_presence :cmsfile
  validates_attachment_content_type :cmsfile, :content_type => ['application/pdf', 'text/plain','application/octet-stream','application/msword']
  validates_attachment_size(:cmsfile, :less_than => 5.megabytes)
  #file_column :file_path
   # validates_presence_of :file_path
  # validates_presence_of :file_path

  def comment_size
    self.comments.size
  end

  def rate_size
    self.rating.to_i
  end

end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: article_files
#
#  id                       :integer(4)      not null, primary key
#  article_id               :integer(4)
#  articlefile_file_name    :string(255)
#  articlefile_content_type :string(255)
#  articlefile_file_size    :integer(4)
#  articlefile_updated_at   :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

class ArticleFile < ActiveRecord::Base
  belongs_to :article
  #file_column :file_path
  has_attached_file :articlefile
  validates_attachment_presence :articlefile,
                                    :url =>    "/uploaded_files/articlefile/:id/:style/:basename.:extension",
                                   :path => ":rails_root/public/uploaded_files/articlefile/:id/:style/:basename.:extension"
  validates_attachment_size(:articlefile, :less_than => 100.megabytes)
  #validates_presence_of :file_path
end

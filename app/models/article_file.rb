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

# This class is defining the an object containing a file link to an article,
# in order to manage the 1-N relation between an article and a file.
#
class ArticleFile < ActiveRecord::Base

  # Relation N-1 to the table 'articles'
  belongs_to :article
	# Declaration of the field to index inside ActsAsXapian index
  acts_as_xapian :texts => [:articlefile_file_name]
  # Paperclip attachment definition
  has_attached_file :articlefile
  # Validation of the presence of a attached file
  validates_attachment_presence :articlefile,
    :url =>    "/uploaded_files/articlefile/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/articlefile/:id/:style/:basename.:extension"
  # Validation of the size of the attached file
  validates_attachment_size(:articlefile, :less_than => 100.megabytes)

end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: article_files
#
#  id         :integer(4)      not null, primary key
#  article_id :integer(4)
#  file_path  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ArticleFile < ActiveRecord::Base
  belongs_to :article
  file_column :file_path
  
  validates_presence_of :file_path
end

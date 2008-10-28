class ArticleFile < ActiveRecord::Base
  belongs_to :article
  file_column :file_path
  
  validates_presence_of :file_path
end

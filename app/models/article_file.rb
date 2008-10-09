class ArticleFile < ActiveRecord::Base
	belongs_to :article
	file_column :file_path	
end

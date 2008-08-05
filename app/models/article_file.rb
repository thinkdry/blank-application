class ArticleFile < ActiveRecord::Base
	
	belongs_to :article
	belongs_to :artic_file
	
end

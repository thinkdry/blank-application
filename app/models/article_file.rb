class ArticleFile < ActiveRecord::Base
	
	belongs_to :article
	
	file_column :file_path
	
	def self.label
	  "Fichier"
	end
	
end

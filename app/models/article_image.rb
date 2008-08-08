class ArticleImage < ActiveRecord::Base
	
	belongs_to :article
	
	file_column :image_path

end

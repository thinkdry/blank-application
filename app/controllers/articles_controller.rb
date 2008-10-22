class ArticlesController < ApplicationController
  acts_as_ajax_validation
  acts_as_item
	
	def removeFile
	  permit "edition of article"
		if ArticleFile.find(params[:id]).destroy
			render :nothing => true
		else
			render :nothing => true
    end
  end
	
end
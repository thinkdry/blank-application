class ArticlesController < ApplicationController
  acts_as_ajax_validation
  acts_as_item
	
	# TODO: Same rights than edit and update (see acts_as_item lib)
	def removeFile
		if ArticleFile.find(params[:id]).destroy
			render :nothing => true
		else
			render :nothing => true
    end
  end
	
end
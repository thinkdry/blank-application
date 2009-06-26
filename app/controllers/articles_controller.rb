require 'fileutils'

class ArticlesController < ApplicationController
          

  acts_as_ajax_validation
  acts_as_item do

		after :create do
			if !(Dir[RAILS_ROOT+"/public/uploaded_files/article/#{current_user.login}_#{current_user.id}"]).blank?
				FileUtils.mv(RAILS_ROOT+"/public/uploaded_files/article/#{current_user.login}_#{current_user.id}", RAILS_ROOT+"/public/uploaded_files/article/#{@current_object.id}")
				@current_object.body = @current_object.body.sub(current_user.login+'_'+current_user.id.to_s, @current_object.id.to_s)
				@current_object.save
			end
		end

		response_for :create do |format|
			format.html { redirect_to edit_item_path(@current_object) }
			format.xml { render :xml => @current_object }
			format.json { render :json => @current_object }
		end

	end

  
  # Remove File Associated with the Article
	def removeFile
	  object = ArticleFile.find(params[:id])
		if object.article.accepts_edit_for?(@current_user)
			if ArticleFile.find(params[:id]).destroy
				render :nothing => true
			else
				render :nothing => true
			end
		end
  end
# TODO 'removeFile' should be made to ruby style method name ex: remove_associated_file
end
require 'fileutils'

# This controller is managing the different actions relative to the Article item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class ArticlesController < ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do
		after :create do
			if !(Dir[RAILS_ROOT+"/public/uploaded_files/article/#{current_user.login}_#{current_user.id}"]).blank?
				FileUtils.mv(RAILS_ROOT+"/public/uploaded_files/article/#{current_user.login}_#{current_user.id}", RAILS_ROOT+"/public/uploaded_files/article/#{@current_object.id}")
				@current_object.body = @current_object.body.sub(current_user.login+'_'+current_user.id.to_s, @current_object.id.to_s)
				@current_object.save
			end
		end
		# After the creation, redirection to the edition in order to be able to set the body
		response_for :create do |format|
			format.html { redirect_to edit_item_path(@current_object) }
			format.xml { render :xml => @current_object }
			format.json { render :json => @current_object }
		end
	end
  
  # Remove a file associated with the article
  #
	# This function is linked to an url allowing to delete the file linked to the article through an AJAX request.
	def remove_file
	  object = ArticleFile.find(params[:id])
		if object.article.has_permission_for?('edit', @current_user)
			if ArticleFile.find(params[:id]).destroy
				render :nothing => true
			else
				render :nothing => true
			end
		end
  end
	
end
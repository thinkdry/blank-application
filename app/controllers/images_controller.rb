class ImagesController < ApplicationController  
  acts_as_ajax_validation
	acts_as_item

	def get_file_url
		@current_object = Image.find(params[:id])
		redirect_to @current_object.image.url
	end

end
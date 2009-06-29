class ImagesController < ApplicationController  
  acts_as_ajax_validation
	acts_as_item

  # Return the Url of the Image for Pop Up Window
	def get_file_url
		@current_object = Image.find(params[:id])
		redirect_to @current_object.image.url
	end

  # Return Download Link for Image File
  def download
    @image = Image.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@image.image.url.split("?")[0], :disposition => 'inline', :stream => false)
  end

end
class ImagesController < ApplicationController  
  acts_as_ajax_validation
	acts_as_item

  # Return the Url of the Image for Pop Up Window
  # 
  # Usage URL:
  # 
  # /images/get_file_url/:id
  #
	def get_file_url
		@current_object = Image.find(params[:id])
		redirect_to @current_object.image.url
	end

  # Return Download Link for Image File
  # 
  # # Usage URL:
  #
  # /images/download/:id
  #
  def download
    @image = Image.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@image.image.url.split("?")[0], :disposition => 'inline', :stream => false)
  end

end
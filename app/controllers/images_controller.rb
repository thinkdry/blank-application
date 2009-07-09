class ImagesController < ApplicationController  
  acts_as_ajax_validation
	acts_as_item

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
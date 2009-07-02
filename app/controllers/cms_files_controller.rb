class CmsFilesController < ApplicationController
  acts_as_ajax_validation
  acts_as_item

  # Return the Url of the CmsFile for Pop Up Window
  #
  # Usage URL:
  #
  # /cms_files/get_file_url?id=1
  #
	def get_file_url
		@current_object = CmsFile.find(params[:id])
		redirect_to @current_object.cmsfile.url
	end

  # Return Download Link for CmsFile File
  #
  # Usage URL:
  #
  # /cms_files/download/:id
  #
  def download
    @image = Image.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@image.image.url.split("?")[0], :disposition => 'inline', :stream => false)
  end

end
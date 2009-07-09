class CmsFilesController < ApplicationController
  acts_as_ajax_validation
  acts_as_item


  # Return Download Link for CmsFile File
  #
  # Usage URL:
  #
  # /cms_files/download/:id
  #
  def download
    @cms_file = CmsFile.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@cms_file.cmsfile.url.split("?")[0], :disposition => 'inline', :stream => false)
  end

end
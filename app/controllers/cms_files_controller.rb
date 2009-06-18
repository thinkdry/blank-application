class CmsFilesController < ApplicationController
  acts_as_ajax_validation
  acts_as_item

	def get_file_url
		@current_object = CmsFile.find(params[:id])
		redirect_to @current_object.cmsfile.url
	end

end
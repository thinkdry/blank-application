# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class ImagesController < ApplicationController  

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
	acts_as_item

  # Download the file link to an Image item
  #
	# This function is linked to an url allowing to get the file by downloading
	# (and not trying to open it with the browser)
  def download
    @image = Image.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@image.image.url.split("?")[0], :disposition => 'inline', :stream => false)
  end

end
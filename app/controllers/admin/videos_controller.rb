# This controller is managing the different actions relative to the Video item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::VideosController < Admin::ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
	acts_as_item do
		#Filter calling the encoder method of ConverterWorker with parameters
    after :create, :update do
      @current_object.update_attributes(:state => 'uploaded')
      Delayed::Job.enqueue(EncodingJob.new({:type=>"video", :id => @current_object.id, :enc=>"flv"}))
    end
  end

  # AJAX action to get the encoding progress through Backgroundrb Converter Worker
  #
  # This function is linked to an url and called by an AJAX request.
  def get_video_progress
    @current_object = Video.find(params[:id].to_i)
    if params[:check] && params[:check] == 'true'
      render :text => @current_object.state
    elsif params[:status]
      render :text => @current_object.state
    else
      render :update do |page|
        page.replace_html "states", :partial => 'player', :object => @current_object
      end
    end
  end

  # Action to download the file link to an Video item
  #
	# This function is linked to an url allowing to get the file by downloading
	# (and not trying to open it with the browser)
  def download
    @video = Video.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@video.video.url.split("?")[0], :disposition => 'inline', :stream => false)
  end
end

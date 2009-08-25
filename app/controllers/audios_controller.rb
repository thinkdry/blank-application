# This controller is managing the different actions relative to the Audio item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class AudiosController < ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do
		#Filter calling the encoder method of ConverterWorker with parameters
    after :create, :update do
      @current_object.update_attributes(:state => 'uploaded')
      Delayed::Job.enqueue(EncodingJob.new({:type=>"audio", :id => @current_object.id, :enc=>"mp3"}))
      #MiddleMan.worker(:converter_worker).async_newthread(:arg=>{:type=>"audio", :id => @current_object.id, :enc=>"mp3"})
    end
  end

  # AJAX action to get the encoding progress through Backgroundrb Converter Worker
  #
  # This function is linked to an url and called by an AJAX request.
  def get_audio_progress
    @current_object=Audio.find(params[:id])
    if params[:check] && params[:check] == 'true'
      render :text => @current_object.state
    else
      render :partial=>"player", :object => @current_object
    end
  end

  # Action to download the file link to an Audio item
  #
	# This function is linked to an url allowing to get the file by downloading
	# (and not trying to open it with the browser)
  def download
    @audio = Audio.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@audio.audio.url.split("?")[0], :disposition => 'inline', :stream => false)
  end
end
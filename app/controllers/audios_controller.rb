class AudiosController < ApplicationController
  acts_as_ajax_validation

  acts_as_item do
    after :create, :update do
      #Call the encoder method of ConverterWorker with Parameters
      @current_object.update_attributes(:state=>"uploaded")
      MiddleMan.worker(:converter_worker).async_newthread(:arg=>{:type=>"audio", :id => @current_object.id, :enc=>"mp3"})
    end
  end

  # Method to Get Progress of Encoding through Backgroundrb Converter Worker
  def get_audio_progress
    @current_object=Audio.find_by_id(params[:id])
    if params[:check] && params[:check] == 'true'
      render :text => @current_object.state
    else
      render :partial=>"player", :object => @current_object
    end
  end

  # Return the Url of the Audio for Pop Up Window
	def get_file_url
		@current_object = Audio.find(params[:id])
		redirect_to @current_object.audio.url
	end

  # Return Download Link for Audio File
  def download
    @audio = Audio.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@audio.audio.url.split("?")[0], :disposition => 'inline', :stream => false)
  end
end
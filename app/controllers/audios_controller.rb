class AudiosController < ApplicationController
  acts_as_ajax_validation
  acts_as_item do
    after :create, :update do
      #Call the encoder method of ConverterWorker with Parameters
      @current_object.update_attributes(:state=>"uploaded")
      MiddleMan.worker(:converter_worker).async_newthread(:arg=>{:type=>"audio", :id => @current_object.id, :enc=>"mp3"})
    end
  end
  
  def get_audio_progress
    @current_object=Audio.find_by_id(params[:id])
    if params[:check] && params[:check] == 'true'
      render :text => @current_object.state
    else
      render :partial=>"player", :object => @current_object
    end
  end

  def download
    @audio = Audio.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@audio.audio.url.split("?")[0], :disposition => 'inline', :stream => false)
  end
end
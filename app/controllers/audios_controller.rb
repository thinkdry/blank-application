class AudiosController < ApplicationController
  acts_as_ajax_validation
  acts_as_item do
    after :create, :update do
      #Call the encoder method of ConverterWorker with Parameters
      MiddleMan.worker(:converter_worker).encoder(:arg=>{:type=>"audio", :id => @current_object.id, :enc=>"mp3"})
    end
  end
  def get_progress
    @current_object=Audio.find_by_id(params[:id])
    if @current_object.state=="encoded" || @current_object.state=="error"
      render :update do |page|
        page.reload
      end
   else
     render :text => @current_object.state
   end
  end
end
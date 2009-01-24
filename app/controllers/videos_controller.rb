class VideosController < ApplicationController	
  acts_as_ajax_validation
	acts_as_item do
     after :create, :update do
         #Call the encoder method of ConverterWorker with parameters
         @current_object.update_attributes(:state=>"uploaded")
         MiddleMan.worker(:converter_worker).async_encoder(:arg=>{:type=>"video", :id => @current_object.id, :enc=>"flv"})

#TODO
#Get the Uploaded Tempfile Directly and Upload in Background
#         if params[:tmp][:video_path]
#           uri=URI.parse(params[:tmp][:video_path])
#           session[:video_path]= params[:tmp][:video_path]
#           p session[:video_path]
#           p params[:tmp][:video_path]
#           p ActionController::UploadedTempfile.new(params[:tmp][:video_path].path.split("/").last)
#           p ActionController::UploadedTempfile.new(params[:tmp][:video_path]).methods.sort
#           p ActionController::UploadedTempfile.new(params[:tmp][:video_path]).original_filename
#           p ActionController::UploadedTempfile.new(params[:tmp][:video_path]).to_param
#           p ActionController::UploadedTempfile.new(params[:tmp][:video_path]).to_tempfile()    
     end

  end

  def get_progress
    @current_object=Video.find_by_id(params[:id])
    if @current_object.state=="encoded" || @current_object.state=="error"
      render :update do |page|
        page.reload
      end
   else
     render :text => @current_object.state
   end
  end
end
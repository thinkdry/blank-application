class VideosController < ApplicationController	
  acts_as_ajax_validation
	acts_as_item do
     after :create do
         #MiddleMan.new_worker(:worker=>:converter_worker, :worker_key=>"encoder",:args=>{:type=>"video", :id => @current_object.id, :path=>params[:tmp][:video_path], :enc=>"flv"})
         if params[:tmp][:video_path]
           session[:video_path]= params[:tmp][:video_path].path
           p session[:video_path]
           #session[:video_path]=params[:tmp][:video_path]
           #p session[:video_path]
#         worker=MiddleMan.worker(:converter_worker)
#         data={:type=>"video", :id => @current_object.id, :enc=>"flv"}
#         worker.encoder(:arg=>data)
         end
         #MiddleMan.worker(:converter_worker).encoder(:args=>"hell")
       end
      end
   end
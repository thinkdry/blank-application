class VideosController < ApplicationController	
  acts_as_ajax_validation
	acts_as_item
	
	def encodeVideo
		# Upload of the video on HeyWatch
		@uploaded_video = HeyWatch::Video.create(:file => @current_object.file_path, :title => @current_object.title) do |percent, total_size, received|
			
    end
		# Encode the video in the desired format (31 = FLV)
		@encoded_video = HeyWatch::Job.create(:video_id => @uploaded_video.id, :format_id => 31) do |progress|
			
    end
		# Create the thumbnail of the video
		thumb = HeyWatch::EncodedVideo.find(@encoded_video.id).thumbnail :start => 15, :width => 320, :height => 240
		# Download the encoded video
		downloaded_video_path = HeyWatch::EncodedVideo.find(@encoded_video.id).download('/tmp') do |progress| 
			#puts progress.to_s + '%'
    end
		
		@current_object.encoded_file_path = downloaded_video_path
		@current_object.save
		
		
	end
	
end
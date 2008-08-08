class Video < ActiveRecord::Base
  acts_as_item
  
	belongs_to :user
	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path,
		:user
	
	after_save :encodeVideo
	
	def file_path= arg
		super arg
		# p "coco"
		#afert_save(:encodeVideo)
  end
	
	def encodeVideo
		# Upload of the video on HeyWatch
		@uploaded_video = HeyWatch::Video.create(:file => self.file_path, :title => self.title) do |percent, total_size, received|
			
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
		
		self.encoded_file_path = downloaded_video_path
		self.save
		
		
	end
	
end

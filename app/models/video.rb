# == Schema Information
# Schema version: 20181126085723
#
# Table name: videos
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)     default("initial")
#  video_file_name    :string(255)
#  video_content_type :string(255)
#  video_file_size    :integer(4)
#  video_updated_at   :datetime
#  encoded_file       :string(255)
#  thumbnail          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  viewed_number      :integer(4)      default(0)
#  rates_average      :integer(4)      default(0)
#  comments_number    :integer(4)      default(0)
#

# This class is defining an item object called 'Video'.
#
# You can use it to upload an video file in the Blank application,
# according to the file types available and the size of the file.
# Your video file will automatically be converted into FLV (Flash video format) on the server,
# using the FFMPEG encoder (launched through Backgroundrb plugin, 'converter_worker' task).
#
# On the show page, a Flash player will allow you to play this file.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Video < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item
  # Paperclip attachment definition
  has_attached_file :video,
		:url =>    "/uploaded_files/video/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/video/:id/:style/:basename.:extension"
  # P# Validation of the presence of a attached file
  validates_attachment_presence :video
	# Validation of the type of the attached file
  #validates_attachment_content_type :video, :content_type => ['video/quicktime','video/x-flash-video', 'video/x-flv', 'video/mpeg','video/3gpp', 'video/x-msvideo']
	# Validation of the size of the attached file
  validates_attachment_size(:video, :less_than => 100.megabytes)

  # After Save Callback to encode video
  #after_save {|record| Delayed::Job.enqueue(EncodingJob.new({:type=>"video", :id => record.id, :enc=>"flv"}))}

	# Media type used for the FLV encoding
  #
	# This method returns a media type used inside the 'converter_worker' task during the encoding.
	#
  # Usage :
  # <tt>object.media_type</tt>
	def media_type
    video
  end

  def path_to_encoded_file
    file_ext = self.video_file_name.split('.').last
    File.dirname(self.video.url) + "/" + self.video_file_name.delete(file_ext) + "flv"
  end

  # Codec used for the MP3 encoding (general video file)
  #
	# This method returns the codec and parameters used by FFMPEG
	#  for encoding the file atached into FLV format (inside 'converter worker' task).
	#
  # Usage :
  # <tt>object.codec</tt>
  def codec
    if RAILS_ENV == 'development'
      "-ar 22050 -ab 32 -f flv -y"
    else
     "-vcodec libx264 -vpre hq -ar 22050 -ab 32 -crf 15"
    end
  end

  # Codec used for the MP3 encoding (in the case of 3gp file)
  #
	# This method returns the codec and parameters used by FFMPEG
	# for encoding the 3gp attached file into FLV format (inside 'converter worker' task).
	#
  # Usage :
  # <tt>object.codec_3gp</tt>
  def codec_3gp
    "-ar 22050 -ab 32 -sameq -an -y"
  end

end

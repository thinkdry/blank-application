# == Schema Information
# Schema version: 20181126085723
#
# Table name: audios
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)     default("initial")
#  audio_file_name    :string(255)
#  audio_content_type :string(255)
#  audio_file_size    :integer(4)
#  audio_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  viewed_number      :integer(4)      default(0)
#  rates_average      :integer(4)      default(0)
#  comments_number    :integer(4)      default(0)
#

# This class is defining an item object called 'Audio'.
#
# You can use it to publish an audio content from different format like MP3, OGG, ... .
# Your audio file will automatically be converted into MP3 on the server,
# using the FFMPEG encoder (launched through Backgroundrb plugin, 'converter_worker' task).
#
# On the show page, a Flash player will allow you to play this file.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Audio < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item
  # Paperclip attachment definition
  has_attached_file :audio,
    :url =>  "/uploaded_files/audio/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/audio/:id/:style/:basename.:extension"
  # Validation of the presence of a attached file
  validates_attachment_presence :audio
	# Validation of the type of the attached file
  #validates_attachment_content_type :audio, :content_type => ['audio/wav','audio/x-wav', 'audio/mpeg', 'audio/x-ms-wma', 'video/mp4' ]
	# Validation of the size of the attached file
  validates_attachment_size(:audio, :less_than => 25.megabytes)

  # Callbacks
  #after_save { |record| Delayed::Job.enqueue(EncodingJob.new({:type=>"audio", :id => record.id, :enc=>"mp3"})) }

  # Media type used for the MP3 encoding
  #
	# This method returns a media type used inside the 'converter_worker' task during the encoding.
	#
  # Usage :
  # <tt>object.media_type</tt>
  def media_type
    audio
  end

  def path_to_encoded_file
    file_ext = self.audio_file_name.split('.').last
    File.dirname(self.audio.url) + "/" + self.audio_file_name.delete(file_ext) + 'mp3'
  end

  # Codec used for the MP3 encoding
  #
	# This method returns the codec used by FFMPEG for the encoding (inside 'converter worker' task).
	#
  # Usage :
  # <tt>object.codec</tt>
  def codec
    "-acodec libmp3lame -y"
  end

end

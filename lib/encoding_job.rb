class EncodingJob < Struct.new(:args)

  def perform
    object=args[:type].classify.constantize.find_by_id(args[:id])
    success = system(convert_media(args[:type], object, args[:enc]))
    if success && $?.exitstatus == 0
      object.update_attributes(:state=>"encoded")
      if args[:type]=="video"
        i=1
        j=2
        pic=4
        while i<=pic do
          system(thumbnail(i,j,object))
          i=i+1
          j=j*3
        end
      end
    else
      object.update_attributes(:state=>"encoding_error")
    end

  end

  # Method to convert the media to desired media (Default MP3 for Audio and FLV for Video)
  def convert_media(type, object, enc)
    media = File.join(File.dirname(object.media_type.path), "#{type}.#{enc}")
    File.open(media, 'w')
    if object.media_type.content_type.include?("audio/mpeg") || object.media_type.content_type.include?("video/x-flash-video") || object.media_type.content_type.include?("video/x-flv")
      command=<<-end_command
         cp  #{ object.media_type.path } #{media}
      end_command
      command.gsub!(/\s+/, " ")
    elsif object.media_type.content_type.include?("video/3gpp")
      command = <<-end_command
         ffmpeg -i #{ object.media_type.path } #{object.codec_3gp} #{ media }
      end_command
      command.gsub!(/\s+/, " ")
    else
      command = <<-end_command
        ffmpeg -i #{ object.media_type.path } #{object.codec} #{ media }
      end_command
      command.gsub!(/\s+/, " ")
    end
  end

  # Create Thumbnails for Video File on Particular Intervals
  def thumbnail(i,j,object)
    thumb = File.join(File.dirname(object.media_type.path), "#{i.to_s}.png")
    File.open(thumb, 'w')
    command=<<-end_command
    ffmpeg  -itsoffset -#{(i*j).to_s}  -i #{File.dirname(object.media_type.path)}/video.flv -vcodec png -vframes 1 -an -f rawvideo -s 470x320 -y #{thumb}
    end_command
    command.gsub!(/\s+/, " ")
  end
end




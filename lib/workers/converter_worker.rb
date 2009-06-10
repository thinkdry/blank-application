class ConverterWorker < BackgrounDRb::MetaWorker

  set_worker_name :converter_worker
  pool_size 5
  
  def create(args = nil)
    puts "Started BackgrounDRb for Encoding"
    @retried = false
  end

  def newthread(args)
    object=args[:type].classify.constantize.find_by_id(args[:id])
    object.update_attributes(:state=>"encoding")
    thread_pool.defer(:encoder,args)
  end
  
  def encoder(args)
    logger.info "Encoder Called"
    logger.info  "#{args[:type].capitalize} Encoding"
    object=args[:type].classify.constantize.find_by_id(args[:id])
    success = system(convert_media(args[:type], object, args[:enc]))
    if success && $?.exitstatus == 0
      object.update_attributes(:state=>"encoded")
      logger.info "Encoded #{args[:type]} on id #{args[:id]}"
      if args[:type]=="video"
        i=1
        j=2
        pic=4
        while i<=pic do
          system(thumbnail(i,j,object))
          i=i+1
          j=j*3
        end
        logger.info "Thumbnails Created #{args[:type]} on id #{args[:id]}"
      end
    else
      object.update_attributes(:state=>"encoding_error")
      logger.info "Encoding #{args[:type]} Failed on Id #{args[:id]}"
    end
  
  end
 
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
      logger.info "Encoding #{type}"
      command = <<-end_command
        ffmpeg -i #{ object.media_type.path } #{object.codec} #{ media }
      end_command
      command.gsub!(/\s+/, " ")
    end
  end

  def thumbnail(i,j,object)
    thumb = File.join(File.dirname(object.media_type.path), "#{i.to_s}.png")
    File.open(thumb, 'w')
    command=<<-end_command
    ffmpeg  -itsoffset -#{(i*j).to_s}  -i #{File.dirname(object.media_type.path)}/video.flv -vcodec png -vframes 1 -an -f rawvideo -s 470x320 -y #{thumb}
    end_command
    command.gsub!(/\s+/, " ")
  end
end

#ffmpeg -i #{File.dirname(object.media_type.path)}/video.flv -an -ss 00:00:3 -an -r 1 -vframes 1 -y #{thumb}
#ffmpeg  -itsoffset -4  -i public/videos/#{video_name} -vcodec mjpeg -vframes 1 -an -f rawvideo -s 160x120 public/images/thumbs/#{videoname}.jpg
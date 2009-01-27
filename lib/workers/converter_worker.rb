class ConverterWorker < BackgrounDRb::MetaWorker

  set_worker_name :converter_worker
  def create(args = nil)
    puts "Started BackgrounDRb for Encoding"
  end
  
  def encoder(args)
    logger.info "Encoder Called"
    logger.info  "#{args[:type].capitalize} Encoding"
    object=args[:type].classify.constantize.find_by_id(args[:id])
    object.update_attributes(:state=>"encoding")
    success = system(convert_media(args[:type], object, args[:enc]))
     if success && $?.exitstatus == 0
        object.update_attributes(:state=>"encoded")
        logger.info "Encoded #{args[:type]} on id #{args[:id]}"
        if args[:type]=="video"
          system(thumbnail(object,pic=4))
           logger.info "Thumbnails Created #{args[:type]} on id #{args[:id]}"
        end
     else
        object.update_attributes(:state=>"error")
        logger.info "Encoding #{args[:type]} Failed on Id #{args[:id]}"
     end
   end
 
  def convert_media(type, object, enc)
    media = File.join(File.dirname(object.media_type.path), "#{type}.#{enc}")
    File.open(media, 'w')
      if object.media_type.content_type.include?("audio/mpeg") || object.media_type.content_type.include?("video/x-flash-video")
         command=<<-end_command
         cp  #{ object.media_type.path } #{media}
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

  def thumbnail(object,pic)
    (1..pic.to_i).each do |i|
    i=i.to_s
    thumb = File.join(File.dirname(object.media_type.path), "#{i}.png")
    File.open(thumb, 'w')
    command=<<-end_command
  ffmpeg  -itsoffset -#{i.to_i*4}  -i #{File.dirname(object.media_type.path)}/video.flv -vcodec png -vframes 1 -an -f rawvideo -s 470x320 #{thumb}
    end_command
    command.gsub!(/\s+/, " ")
    end
  end
end


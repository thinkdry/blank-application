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
end


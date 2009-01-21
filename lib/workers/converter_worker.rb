class ConverterWorker < BackgrounDRb::MetaWorker
  set_worker_name :converter_worker
  def create(args = nil)
    puts "Started BackgrounDRb for Encoding"
  end
  
  def encoder(args)
    logger.info "Encoder Called"
    logger.info  "#{args[:type].capitalize} Encoding"
    logger.info  session[:video_file]
    logger.info args[:file]
#    object=args[:type].classify.constantize.find_by_id(args[:id])
#    success = system(convert_media(args[:type],object,args[:enc]))
#     if success && $?.exitstatus == 0
#        object.update_attributes(:state=>"converted")
#     else
#         object.update_attributes(:state=>"error")
#     end
   end
 
  def convert_media(type,object,enc)
    #Create New File
     media = File.join(File.dirname(object.video.path), "converted.#{enc}")
     File.open(media, 'w')
     #Converting on Command Line
     logger.info "Converting #{type}"
     command = <<-end_command
      ffmpeg -i #{ object.video.path }  -ar 44100  -ab 96 -f flv -y #{ media }
     end_command
     command.gsub!(/\s+/, " ")
    end
end


module HeyWatch
  class VideoNotFound < RuntimeError; end
  class MultipleVideoFound < RuntimeError; end

  class Discover < Base   
    # Discover video from the given URL
    #
    # If you pass a block, you will follow the process until you get the raw video.
    # Return the new video if pass a block.
    #
    # If more than 1 video is found, raise an exception.
    #
    #   Discover.create(:url => 'http://host.com/', :download => true) {|percent, total_size, received| ...}
    def self.create(attributes={}, &block)
      discover = super
      return discover unless attributes[:download] and block_given?
      
      while (discover.status rescue "working") == "working"
        discover.reload rescue nil
      end

      case discover.status
      when "ok"
        if discover.results.result.is_a?(String)
          while discover.download_id.nil?
            sleep 1
            discover.reload
          end
          video = Download.progress(discover.download, &block)
          return video
        else
          raise MultipleVideoFound, "You have to choose the video you want to transfer"
        end
      when "error"
        raise VideoNotFound, "No video found in this website"
      end
    end
  end
end

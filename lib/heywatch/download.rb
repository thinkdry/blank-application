module HeyWatch
  class DownloadFailed < RuntimeError; end

  class Download < Base   
    # Download file from the given URL
    #
    # If you pass a block, you get the progress. Return the new video.
    #
    #   Download.create(:url => 'http://host.com/file.avi') {|percent, total_size, received| ...}
    def self.create(attributes={}, &block)
      download = super
      return download unless block_given?
      self.progress(download, &block)
    end

    def self.progress(download, &block)
      while download.status == "downloading"
        download.reload
        yield download.progress.percent, download.length, download.progress.current_length
        sleep 1
      end
      case download.status
      when "finished"
        return download.video
      when "error"
        raise DownloadFailed, download.error_msg
      end
    end
  end
end

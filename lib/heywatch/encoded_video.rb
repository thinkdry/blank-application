module HeyWatch
  class EncodedVideo < Base
    def url
      res = Browser::get("#{self.class.path}/#{self.id}.bin", self.class.session)
      HeyWatch::sanitize_url(res.get_fields("Location").first)
    end
    
    # Generate a thumbnail of the encoded video
    #
    # options:
    # * <tt>start:</tt> offset in second
    # * <tt>width</tt>
    # * <tt>height</tt>
    #
    # All these options are optionals. Return binary data.
    #
    #  EncodedVideo.find(:first).thumbnail :start => 15, :width => 320, :height => 240
    def thumbnail(options={})
      param = options.to_a.map{|v| v.join("=")}.join("&")
      res = Browser::get("#{self.class.path}/#{self.id}.jpg#{'?'+param unless param.empty?}", self.class.session)
      case res
      when Net::HTTPRedirection
        Net::HTTP.get_response(URI(HeyWatch::sanitize_url(res["location"]))).body
      else
        res.body
      end
    end
    
    # Download the encoded video
    #
    # The path is . by default. You can pass a block to have progression. Return the full path of the video.
    #
    #   EncodedVideo.find(:first).download('/tmp') {|progress| puts progress.to_s + '%'}
    def download(path=".")
      uri = URI(url)
      size = self.specs["size"] * 1024
      path = File.join(path, self.filename)
      file = File.open(path, "wb")
      Net::HTTP.start(uri.host) do |http| 
        http.get(uri.path) do |data|
          file.write data
          yield((File.size(path) / size.to_f) * 100) if block_given?
        end
      end
      file.close
      return path
    end
  end
end

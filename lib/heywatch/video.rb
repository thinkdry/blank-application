module HeyWatch
  class Video < Base
    # Upload a video to Hey!Watch
    #
    # If you pass a block, you get the current progression. Return the new video.
    #
    #   Video.create(:file => 'myvideo.avi', :title => 'my new video') {|percent, total_size, received| ...}
    def self.create(attributes={})
      upload_id = rand(99999**2)
      if block_given?
        t = Thread.new do
          loop do
            res = HeyWatch::response(Browser::get("/upload/#{upload_id}", self.session).body)
            percent = (res.received.to_i / res["size"].to_f) * 100
            yield percent, res["size"], res.received
            sleep 1
          end
        end
      end
      video = new(HeyWatch::response(Browser::post_multipart("/upload?upload_id=#{upload_id}", attributes, self.session).body))
      t.kill if block_given?
      return video
    end
  end
end

module HeyWatch
  class JobFailed < RuntimeError; end
  
  class Job < Base
    # Encode the given video into the given format
    #
    # If you pass a block, you get the progress. Return the new encoded video.
    # If the job failed, the method will raise with the error message.
    #
    #   Job.create(:video_id => 105, :format_id => 5) {|progress| ...}
    def self.create(attributes={}, &block)
      job = super
      return job unless block_given?
      self.progress(job, &block)
    end

    def self.progress(job, &block)
      while job.status == "pending" or job.status == "working"
        job.reload
        yield job.progress rescue 0
        sleep 1
      end
      
      case job.status
      when "finished"
        return job.encoded_video
      when "error"
        raise JobFailed, job.error_msg
      end
    end
  end
end

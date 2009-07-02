class CronjobWorker < BackgrounDRb::MetaWorker
  set_worker_name :cronjob_worker
  pool_size 5

  def create(args = nil)
    puts "Started Worker for FeedSource, Xapian Index Updation & Newsletter"
  end

  # Create New Thread for Sending Newsletter Asynchronously
  def newthread(args)
    thread_pool.defer(:send_newsletter)
  end

  # Method to Update Feed Sources
  def update_feed_source
    logger.info "Updating Feed Sources"
    FeedSource.all.each do |s|
      s.import_latest_items
    end
    logger.info "Updated Feed sources"
  end

  # Method to Update Xapian Indexes
  def update_xapian_index
    logger.info "Updating Xapian Indexes"
    command=<<-end_command
    rake xapian:update_index RAILS_ENV=#{RAILS_ENV}
    end_command
    command.gsub!(/\s+/, " ")
    system(command)
    logger.info "Updated Xapian Indexes"
  end

  # Method to Send Newsletter to Subscribed Members
	def send_newsletter
		logger.info "Sending the newsletters"
		command=<<-end_command
      ruby script/runner QueuedMail.send_email
    end_command
    command.gsub!(/\s+/, " ")
    system(command)
    logger.info "Sent the newsletters on #{Time.now}"
	end

end


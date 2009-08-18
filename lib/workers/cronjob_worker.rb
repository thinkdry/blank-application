class CronjobWorker < BackgrounDRb::MetaWorker
	
  set_worker_name :cronjob_worker
  pool_size 5

  def create(args = nil)
    puts "CronJob Workers initialisation done ..."
  end

  # Create New Thread for Sending Newsletter Asynchronously
  def newthread(args)
    thread_pool.defer(:send_newsletter)
  end

  # Method to Update Feed Sources
  def update_feed_source
    logger.info "#{Time.now} : Updating Feed Sources ..."
    FeedSource.all.each do |s|
			begin
				s.import_latest_items
			rescue
				logger.info "  #{Time.now} : Error updating Feed Source #{s.id}"
			end
    end
    logger.info "#{Time.now} : Updated Feed sources"
  end

  # Method to Update Xapian Indexes
  def update_xapian_index
    logger.info "#{Time.now} : Updating Xapian indexes ..."
    command=<<-end_command
    rake xapian:update_index RAILS_ENV=#{RAILS_ENV}
    end_command
    command.gsub!(/\s+/, " ")
		if system(command)
			logger.info "#{Time.now} : Xapian index update success#{ $?.exitstatus == 0 ? '' : ', but exit status equal to '+exitstatus.to_s }"
		else
			loger.info "#{Time.now} : Xapian index update failed"
		end
  end

  # Method to Send Newsletter to Subscribed Members
	def send_newsletter
		logger.info "#{Time.now} : Sending newsletters ..."
		command=<<-end_command
      ruby script/runner QueuedMail.send_email
    end_command
    command.gsub!(/\s+/, " ")
		if system(command)
			logger.info "#{Time.now} : Newsletter sending success#{ $?.exitstatus == 0 ? '' : ', but exit status equal to '+exitstatus.to_s }"
		else
			loger.info "#{Time.now} : Newsletter sending failed"
		end
	end

end


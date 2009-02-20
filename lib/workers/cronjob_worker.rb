class CronjobWorker < BackgrounDRb::MetaWorker
  set_worker_name :cronjob_worker
  def create(args = nil)
    puts "Started Worker for FeedSource & Xapian Updation"
  end

  def update_feed_source
    logger.info "Updating Feed Sources"
    FeedSource.all.each do |s|
      s.import_latest_items
    end
    logger.info "Updated Feed sources"
  end

  def update_xapian_index
    logger.info "Updating Xapian Indexes"
    command=<<-end_command
    rake xapian:update_index RAILS_ENV=#{RAILS_ENV}
    end_command
    command.gsub!(/\s+/, " ")
    system(command)
    logger.info "Updated Xapian Indexes"
  end

end


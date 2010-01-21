every 2.hours do
  runner "FeedSource.update_feed_source"
end

every 1.hours do
  rake "xapian:update_index"
end

every 2.minutes do
  runner "QueuedMail.send_email"
end

#TODO
# Automatic Backup of Application Database & UploadedFiles & YAML files & Code


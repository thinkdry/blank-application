every 2.hours do
  runner "FeedSource.update_feed_source"
end

every 1.hours do
  rake "xapian:update_index"
end



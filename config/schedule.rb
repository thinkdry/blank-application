every 2.minutes do
  runner "FeedSource.update_feed_source"
end

every 3.minutes do
  rake "xapian:update_index"
end



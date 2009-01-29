namespace :cron do
  namespace :feed_items do
    desc "Update all feed sources (rss)"
    task(:update => :environment) do
      FeedSource.all.each do |s|
        s.import_latest_items
      end
    end
  end
end
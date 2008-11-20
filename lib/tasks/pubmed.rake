namespace :cron do
  namespace :pubmed do
    desc "Update all pubmed sources (rss)"
    task(:update_rss => :environment) do
      FeedSource.all.each do |s|
        s.import_latest_items
      end
    end
  end
end
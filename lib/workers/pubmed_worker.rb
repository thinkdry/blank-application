require 'pubmed'

class PubmedWorker < BackgrounDRb::MetaWorker
  set_worker_name :pubmed_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def retrieve_items pubmed_source
    raise 'PubmedSource invalid' unless pubmed_source

    rss = Pubmed.new(pubmed_source.url).rss
    rss.items.each do |item|
      pubmed_item = PubmedItem.new({
        :guid           => item.guid,
        :pubmed_source  => pubmed_source,
        :title          => item.title,
        :description    => item.description,
        :author         => item.author,
        :link           => item.link })
      pubmed_item.save
    end
  end
  
  def test
  end
end


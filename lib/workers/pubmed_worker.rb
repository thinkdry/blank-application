class PubmedWorker < BackgrounDRb::MetaWorker
  set_worker_name :pubmed_worker
  def create(args = nil)
    # this method is called when worker is loaded for the first time
  end
  
  # TOTO: Auto
  def retrieve_items pubmed_source
    raise 'PubmedSource invalid' unless pubmed_source
    pubmed_source.import_latest_items
  end
end


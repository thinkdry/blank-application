class PubmedWorker < BackgrounDRb::MetaWorker
  set_worker_name :pubmed_worker
  def create(args = nil)
    add_periodic_timer(3600) { retrieve_items }
  end
  
  # TOTO: Auto
  def retrieve_items
    PubmedSource.all.each do |s|
      s.import_latest_items
    end
  end
end


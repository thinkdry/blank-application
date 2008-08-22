require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class Pubmed
  def initialize(addr)
    content = String.new # raw content of rss feed will be loaded here
    open(addr) { |s| content = s.read }
    @rss = RSS::Parser.parse(content, false)
  end
  
  def items
    @rss.items
  end
  
  def rss
    @rss
  end
end

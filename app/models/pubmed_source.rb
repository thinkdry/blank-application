require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class PubmedSource < ActiveRecord::Base
  belongs_to  :user
  has_many    :pubmed_items , :dependent => :delete_all
  
  validates_presence_of :name, :url

  def rss_content
    return @rss if @rss
    
    content = String.new # raw content of rss feed will be loaded here
    open(self.url) { |s| content = s.read }
    @rss = RSS::Parser.parse(content, false)
  end

  def import_latest_items
    rss_content.items.each do |item|
      # Be sure that the item hasnt been imported before
      if pubmed_items.count(:conditions => { :guid => item.guid.content }) <= 0
        pubmed_items.create({
          :guid           => item.guid.content,
          :title          => item.title,
          :description    => item.description,
          :author         => item.author,
          :link           => item.link })
      end
    end
  end
  
  def accepts_role? role, user
	  begin
	    auth_method = "accepts_#{role.downcase}?"
	    return (send(auth_method, user)) if defined?(auth_method)
	    raise("Auth method not defined")
	  rescue Exception => e
	    p(e) and raise(e)
	  end
  end
  
  def accepts_consultation? user
    user_is_admin_or_author?(user)
  end
  
  def accepts_edition? user
    user_is_admin_or_author?(user)
  end
  
  private
  def user_is_admin_or_author?
    # Admin
    return true if user.is_admin?
    # Author
    return true if self.user = user
    false
  end
end

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class FeedSource < ActiveRecord::Base
  belongs_to  :user
  has_many    :feed_items , :dependent => :delete_all
  
  validates_presence_of :name, :url
	validates_uniqueness_of :name, :message => "Ce nom est déjà utilisé."
	validates_uniqueness_of :url, :message => "Ce feed est déjà utilisé."
	
  def validate
    rss_valid?
  end
  
  def rss_valid?
    begin
      rss_content
    rescue Exception => e
      errors.add(:url, "Erreur lors de l'importation des flux, adresse invalide ?")
    end
  end

  def rss_content
    return @rss if @rss
    content = String.new # raw content of rss feed will be loaded here
    open(self.url) { |s| content = s.read }
		if !(content.blank? || content.nil?)
			if (@rss = RSS::Parser.parse(content, false))
				
			else
				p "Impossible de parser le flux "+self.name
				#redirect_to feed_contents_url
			end
		else
			p "Aucun contenu pour l'url "+self.url
			#redirect_to feed_contents_url
		end
  end

  def import_latest_items
		if self.rss_content.items.size > 0
			self.rss_content.items.each do |item|
				# Be sure that the item hasnt been imported before
				if self.feed_items.count(:conditions => { :guid => item.guid }) <= 0
					self.feed_items.create({
						:guid           => item.guid,
						:title          => item.title,
						:description    => item.description,
						:author         => item.author,
						:link           => item.link })
				end
			end
		else
			#flash[:notice] = "RSS unreachable"
			#redirect_to feed_contents_url
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
  def user_is_admin_or_author?(user)
    # Admin
    return true if user.is_admin?
    # Author
    return true if self.user = user
    false
  end
end

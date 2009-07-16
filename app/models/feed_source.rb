# == Schema Information
# Schema version: 20181126085723
#
# Table name: feed_sources
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  etag            :string(255)
#  version         :string(255)
#  encoding        :string(255)
#  language        :string(255)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  url             :string(1024)
#  link            :string(1024)
#  last_updated    :datetime
#  authors         :string(255)
#  categories      :string(255)
#  copyright       :string(255)
#  ttl             :integer(4)
#  image           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#

require 'rss/1.0'
require 'rss/2.0'
require 'regexps'
require 'feedzirra'

class FeedSource < ActiveRecord::Base

  # Item specific Library - /lib/acts_as_item
  acts_as_item
  
	has_many :feed_items , :dependent => :delete_all

  # Validations
  validates_presence_of :url

	validates_format_of :url, :with => /#{URL}/ix, :message=>"The format of the url is not valid."
  
	validate :feed_compliance

  def validate #:nodoc:
    rss_valid?
  end

  
  def rss_valid? #:nodoc:
    begin
      rss_content
    rescue Exception => e
      errors.add(:url, "Erreur lors de l'importation des flux, adresse invalide ?")
    end
  end

  # Check if RSS/Atom Feed can be Parsed for Reading
  #
  # Read the rss_content of the URL and parse it.
  #
  # if it is valid rss then it is accepted or else rejected
  #
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

  def rss_content2 #:nodoc:
    return FeedParser.parse(open(self.url))
  end

  # Import the Latest Updates of the Saved Feeds
  #
  # Usage:
  #
  # feedsource.import_latest_items
  #
  # will update with latest feeds available on the feedsource url
  #
  def import_latest_items
    feed = Feedzirra::Feed.fetch_and_parse(self.url)
    feed.entries.each do |item|
			# Be sure that the item hasnt been imported before
			if self.feed_items.count(:conditions => { :guid => item.id, :feed_source_id => self.id }) <= 0
				FeedItem.create({
            :feed_source_id => self.id,
            :guid						=> item.id,
            :title					=> item.title,
            :description		=> item.summary,
            :authors				=> item.author,
            :date_published => item.published,
            :categories			=> item.categories.join(','),
            :link           => item.url})
			end
		end
  end

  # Check If the given URL is RSS/Atom compliant to Fetch Feed's
  # 
  # will return true if the feed is RSS/Atom compliant else will return false for invalid URL
  #
	def feed_compliance
	  begin
		  open(self.url) do |http|
        response = http.read
        result = RSS::Parser.parse(response, false)
      end
      t = true
    rescue
	    self.errors.add(:url, "The url entered is not a compliant RSS/Atom Feed") 
    end
  end

end

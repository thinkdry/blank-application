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
require 'open-uri'
require 'regexps'
require 'feedzirra'

# This class is defining an item object called 'FeedSource'.
#
# You can use it to define a Web feed by different ways :
# - Checking an existing url on Internet
# - Defining an url of the Blank application (on items list, search results, ... with filters)
#
# On the show page, a button allows you to print the different feed items link to your feed source.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class FeedSource < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item
  # Relation 1-N with the 'feed_sources' table
	has_many :feed_items , :order => "date_published DESC", :dependent => :delete_all
  # Validation of the presence of the 'url' field
  validates_presence_of :url
	# Validation of the format of the 'url' field
	validates_format_of :url, :with => /#{URL}/ix

  validates_not_format_of   :copyright, :with => /(#{SCRIPTING_TAGS})/, :allow_blank => true

  # Check if the given url is a valid rss/xml feed
	#
	# This method will check if the url passed if a valid web feed,
	# and return true if yes, and false if not.
  #
  # Usage :
  # FeedSource.valid_feed('http://somesite.com/articles.rss')
  def self.valid_feed?(feed_url)
    begin
      open(feed_url) do |http|
        p http.content_type
        if http.content_type.include?('rss') ||  http.content_type.include?('xml')
          return true
        else
          return false
        end
      end
    rescue
      return false
    end
    
  end
  
  # Import the Latest Updates of the Saved Feeds
	#
	# This method checks the latest feed items available,
	# and imports them inside the database ('feed_items' table).
  #
  # Usage :
  # feedsource.import_latest_items
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

  def remove_expired_feed_items
    p "Inside expire feed"
    feed_items = self.feed_items.find(:all,:limit => 150)
    if feed_items && feed_items.size >= 150
      self.feed_items.find(:all, :conditions => ["date_published < ?", feed_items.last.date_published]).each do |feed|
        logger.info "Removing Feed Item with id #{feed.id}"
        feed.destroy
      end
    end
  end

	# To implement
	#
	#
  #  def update_existing_feeds
  #    @feeds = FeedSource.all
  #    @feeds.each do |feed|
  #      updated_feed = Feedzirra::Feed.update(feed)
  #      if updated_feed.updated?
  #        updated_feed.new_entries.each do |item|
  #          if self.feed_items.count(:conditions => { :guid => item.id, :feed_source_id => self.id }) <= 0
  #            FeedItem.create({
  #                :feed_source_id => self.id,
  #                :guid						=> item.id,
  #                :title					=> item.title,
  #                :description		=> item.summary,
  #                :authors				=> item.author,
  #                :date_published => item.published,
  #                :categories			=> item.categories.join(','),
  #                :link           => item.url})
  #          end
  #        end
  #      end
  #    end
  #  end

  
end

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

class FeedSource < ActiveRecord::Base

  # Item specific Library - /lib/acts_as_item
  acts_as_item
  
	has_many :feed_items , :dependent => :delete_all

  # Validations
  validates_presence_of :url

	validates_format_of :url, :with => /#{URL}/ix, :message=>"The format of the url is not valid."

  #Check if the given url is a valid rss/xml feed
  #
  # Usage:
  #
  # FeedSource.valid_feed('http://somesite.com/articles.rss')
  #
  # will return true if the feed is a valid rss or else it will return false
  #
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

  def update_existing_feeds
    @feeds = FeedSource.all
    @feeds.each do |feed|
      updated_feed = Feedzirra::Feed.update(feed)
      if updated_feed.updated?
        updated_feed.new_entries.each do |item|
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
    end
  end

  
end

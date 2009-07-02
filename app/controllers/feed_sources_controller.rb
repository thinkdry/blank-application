class FeedSourcesController < ApplicationController
  
	acts_as_ajax_validation
  acts_as_item do

		before :new do
			if params[:url]
				#if (@feed=FeedNormalizer::FeedNormalizer.parse open(params[:url]), :force_parser => FeedNormalizer::SimpleRssParser)
				if 	(@feed=FeedParser.parse(open(params[:url])))
					@current_object = FeedSource.new(
						:etag => @feed.etag,
						:version => @feed.version,
						:encoding => @feed.encoding,
						:language => @feed.feed.language,
						:title => @feed.feed.title,
						:description => @feed.feed.description,
						#:authors => @feed.authors.join(' ,'),
						:categories => @feed.feed.tags ? @feed.feed.tags.map{ |tag| tag["term"]}.to_s : nil,
						:last_updated => @feed.updated,
						:link => @feed.link,
						:url => params[:url],
						:copyright => @feed.rights,
						:ttl => @feed.feed.ttl,
						:image => @feed.image,
						:state => 'copyright'
					)
					flash[:notice] = I18n.t('rss_feed.new.flash_notice_valid')
				else
					flash[:notice] = I18n.t('rss_feed.new.flash_notice_invalid')
					redirect_to 'feed_sources/what_to_to'
				end
			end
		end

    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    
    before :show do
#      permit "consultation of current_object"
			@feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => get_per_page_value)
    end
		
  end

  # Method to Show User How to Get a RSS/ATOM feed
  # 
  # Usage URL:
  # 
  # /feed_sources/what_to_do
  #
	def what_to_do;end

  # Method to Validate the Feed for Blank or if the feed is existing for the User
  # 
  # /feed_sources/check_feed
  #
  def check_feed
		daurl = params[:daurl][:value]
		if daurl.blank?
			flash[:notice] = I18n.t('rss_feed.chek_feed.flash_notice_blank')
			redirect_to '/feed_sources/what_to_do'
		elsif (@feed=FeedSource.find(:first, :conditions => { :url => daurl, :user_id => current_user.id }))
			flash[:notice] = I18n.t('rss_feed.chek_feed.flash_notice_already_subscribed')
			redirect_to feed_source_path(@feed.id)
		else
			redirect_to "/feed_sources/new?url=#{daurl}"
		end
  end
	
end

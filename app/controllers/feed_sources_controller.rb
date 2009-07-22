class FeedSourcesController < ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do
		# 
		before :new do
			if params[:url]
				if 	(@feed=Feedzirra::Feed.fetch_and_parse(params[:url]))
					@current_object = FeedSource.new(
						:etag => @feed.etag,
						:title => @feed.title,
						:description => @feed.url,
						:url => @feed.feed_url,
						:state => 'copyright'
					)
					flash[:notice] = I18n.t('rss_feed.new.flash_notice_valid')
				else
					flash[:error] = I18n.t('rss_feed.new.flash_notice_invalid')
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

  # Method to Validate the Feed for Blank or if the feed is existing for the User
  # 
  # /feed_sources/check_feed
  #
  def check_feed
		daurl = params[:url]
		if daurl.blank?
			render :text => I18n.t('rss_feed.chek_feed.flash_notice_blank')
		elsif (@feed=FeedSource.find(:first, :conditions => { :url => daurl, :user_id => current_user.id }))
			flash[:notice] = I18n.t('rss_feed.chek_feed.flash_notice_already_subscribed')
			render :text => "exists-#{@feed.id}"
		else
      if FeedSource.valid_feed?(daurl)
        render :text => 'new'
      else
        render :text => I18n.t('rss_feed.new.flash_notice_invalid')
      end
		end
  end
	
end

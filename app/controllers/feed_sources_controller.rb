class FeedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	acts_as_ajax_validation
  acts_as_item do
    
    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    
    before :show do
      permit "consultation of current_object"
			@feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => 15)
    end
		
  end
  
  def check_feed
		if (@feed=FeedSource.find(:first, :conditions => { :url => params[:url], :user_id => current_user.id }))
			@what = "already"
		elsif (@feed=FeedNormalizer::FeedNormalizer.parse open(params[:url]), :force_parser => FeedNormalizer::SimpleRssParser)
			@current_object = FeedSource.new(
				:remote_id => @feed.id,
				:title => @feed.title,
				:description => @feed.description,
				:authors => @feed.authors.join(' ,'),
				:last_updated => @feed.last_updated,
				:link => @feed.url,
				:url => params[:url],
				:copyright => @feed.copyright,
				:generator => @feed.generator,
				:ttl => @feed.ttl
				#:image => @feed.image
				)
			@what = "new"
		else
			@what = ""
		end
		render :partial => 'checked_feed' 
  end
	
end

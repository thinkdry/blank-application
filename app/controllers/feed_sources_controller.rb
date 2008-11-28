class FeedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	acts_as_ajax_validation
  acts_as_item do
    
    before :create do
			
    end

    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    
    before :show do
      permit "consultation of current_object"
			@feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => 15)
    end
		
  end
  
  #def current_objects
  #  @current_objects ||= FeedSource.all(:conditions => "user_id = #{@current_user.id}").paginate(
	#		:page => params[:page],
	#		:order => :created_at
	#	)
  #end
	
	def check_feed
		#if (@feed = FeedSource.find(:first, :conditions => { :url => params[:url] }))
		#	@what = "already"
		if (@feed = FeedNormalizer::FeedNormalizer.parse open(params[:url]))
			@current_object = FeedSource.new
			@current_object.title = @feed.title
			@current_object.description = @feed.description
			@current_object.remote_id = @feed.id
			@current_object.authors = @feed.authors
			#@current_object.last_updated = @feed.last_updated
			@current_object.link = @feed.url
			@current_object.url = params[:url]
			@what = "new"
		else
			@what = ""
		end
		render :partial => 'checked_feed' 
  end
	
	def manage_subscription
		if (@rec=FeedSourcesUser.find(:first, :conditions => { :user_id => self.current_user.id, :feed_source_id => params[:feed_source_id].to_i }))
			@rec.destroy
			already = "Adhérer"
		else
			FeedSourcesUser.create(:user_id => self.current_user.id, :feed_source_id => params[:feed_source_id].to_i)
			already = "Résilier"
    end
		#@current_object = FeedSource.find(params[:feed_source_id].to_i)
		render :text => "<input type='button' value='#{already}' onclick=\"new Ajax.Updater('dabutton', '/feed_sources/#{params[:feed_source_id]}/manage_subscription', { parameters: { feed_source_id: #{params[:feed_source_id]} }, method:'get', asynchronous:true, evalScripts:true });\"/>"
  end
	
	
end

class Admin::FeedSourcesController < Admin::ApplicationController
  
  before_filter :check_rss_activation
	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do
	
		before :create do 
			if !@current_object.url.blank?
			  #if the feed exists then display it, otherwise, create it.
			  #feed already existing, redirect it to the display of this feed
			  if object = FeedSource.find_by_url(@current_object.url)
			    #check if object has common workspaces with user ones
			    common_workspaces = (object.workspaces & Workspace.allowed_user_with_permission(@current_user, 'workspace_show', current_container_type)).collect{|ws| ws.id.to_s}
			    
			    if common_workspaces.length > 0
            # let's find in the WS the user selected at the creation, the ones already associated and the other.
            # add the others
            ws_to_associate = params[:feed_source][:associated_workspaces] - common_workspaces
			      ws_to_associate.each do |ws_id|
			        
			        object.workspaces << Workspace.find(ws_id)
			      end		    
			    #user doesn't have this item in his WS, let's add it
			    else
			      object.workspaces << user.get_private_workspace
			    end
			    
			    object.save
          # for automatic redirection on the detected feed
          @current_object = object
        # feed desoen't exists, create it.
        else
          #if the address is valid and Feedzirra can parse the feed, then create the feed.
			    if  FeedSource.valid_feed?(@current_object.url) && 
              @feed=Feedzirra::Feed.fetch_and_parse(@current_object.url)

            @current_object = FeedSource.new( :etag => @feed.etag,
      				                                :title => @feed.title,
      				                                :description => @feed.url,
      				                                :url => @feed.feed_url,
      				                                :state => 'copyright'
      				                                )

            @current_object.associated_workspaces = params[:feed_source][:associated_workspaces]
          end
				end
      end
    end
    
    
    after :create do
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    
    
    before :show do
      #      permit "consultation of current_object"
      @current_object.import_latest_items
      @feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => get_per_page_value)
    end
  end
  
  protected

    def check_rss_activation
      failed_gem_redirection{'plaudix-feedzirra'} unless rss_activated?
    end
end

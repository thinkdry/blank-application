class BookmarksController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  
  acts_as_ajax_validation
  acts_as_item do
		
    before :new, :create do
      # Creation from an FeedItem
      if params[:feed_item_id]
        @feed_item = FeedItem.find(params[:feed_item_id])
        %W(title description enclosures link copyright categories).each do |field|
          @current_object.send("#{field}=", @feed_item.send(field))
				end
				@current_object.state = 'copyright'
      end
		end

		after :create do
			if !(@current_object.state == 'copyright')
				@current_object.date_published = Time.now
				@current_object.save
			end
		end

		after :create, :update do
			if !(@current_object.state == 'copyright')
				#@current_object.last_updated = Time.now
			end
		end
	
	end

end
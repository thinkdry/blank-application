class LinksController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  
  acts_as_ajax_validation
  acts_as_item do
		
    before :new, :create do
      # Creation from an FeedItem
      if params[:feed_item_id]
        @feed_item = FeedItem.find(params[:feed_item_id])
        %W(title description authors link content copyright categories date_published).each do |field|
          @current_object.send("#{field}=", @feed_item.send(field))
        end
      end
		end
	
	end

end
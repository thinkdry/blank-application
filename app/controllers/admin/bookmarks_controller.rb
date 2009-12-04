# This controller is managing the different actions relative to the Bookmark item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::BookmarksController < Admin::ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
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
		# Filter checking the copyright on the bookmark
		after :create do
			if !(@current_object.state == 'copyright')
				@current_object.date_published = Time.now
				@current_object.save
			end
		end
		# 
		after :create, :update do
			if !(@current_object.state == 'copyright')
				#@current_object.last_updated = Time.now
			end
		end
	
	end

end
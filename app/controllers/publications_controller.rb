class PublicationsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  
  acts_as_ajax_validation
  acts_as_item do
    before :new, :create do
      # If the Publication is imported from Pubmed
      # => Export values from the existing PubmedItem to the new Publication
      if params[:feed_item_id]
        @feed_item = PubmedItem.find(params[:feed_item_id])
        
        %W(title description author link).each do |field|
          @current_object.send("#{field}=", @feed_item.send(field))
        end
      end
    end
  end
end

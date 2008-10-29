class PublicationsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  
  acts_as_ajax_validation
  acts_as_item do
    before :new, :create do
      # If the Publication is imported from Pubmed
      # => Export values from the existing PubmedItem to the new Publication
      if params[:pubmed_item_id]
        @pubmed_item = PubmedItem.find(params[:pubmed_item_id])
        
        %W(title description author link).each do |field|
          @current_object.send("#{field}=", @pubmed_item.send(field))
        end
      end
    end
  end
end

class PublicationsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  
  acts_as_ajax_validation
  acts_as_item do
    before :new, :create do
      if params[:pubmed_item_id]
        @pubmed_item = PubmedItem.find(params[:pubmed_item_id])
        [:title, :description, :author, :link].each do |field|
          @current_object.send("#{field}=", sanitize(@pubmed_item.send(field), :tags => %w()))
        end
      end
    end
  end
end

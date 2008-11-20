include ActionView::Helpers::SanitizeHelper

class FeedItem < ActiveRecord::Base
  belongs_to :feed_source
  
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
  
  def description=(value)
    # Remove html tags from description
    #value = strip_tags(value)
    
    # Clean first characters maching
    #     Related Articles
    #     (...)
    #     Authors:  (...)
    value.slice!(/\A[\n\t]*Related Articles.+Authors:[^\n]+\s+/m)
    
    # Remove last characters matching
    #   PMID: 123445
    #   [PubMed - as supplied by publisher]
    value.slice!(/[\n\s]*PMID: \d+ \[PubMed - as supplied by publisher\][\n\s]*\Z/m)
    
    # After our cleaning, call the super method that will assignate the value
    super(value)
  end
end

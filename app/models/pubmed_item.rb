class PubmedItem < ActiveRecord::Base
  belongs_to :pubmed_source
  
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
end

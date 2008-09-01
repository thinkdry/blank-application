class PubmedSource < ActiveRecord::Base
  belongs_to  :user
  has_many    :pubmed_items
  
  validates_presence_of :name, :url
end

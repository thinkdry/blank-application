class PubmedSource < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name, :url
end

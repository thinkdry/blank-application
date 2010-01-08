class WebsiteUrl < ActiveRecord::Base
  belongs_to :website
  
  validates_presence_of :name
	validates_uniqueness_of :name
	
end

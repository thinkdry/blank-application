class Bookmark < ActiveRecord::Base
	
	acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :url]
  
  def self.label
    "Bookmark"
  end
	
end

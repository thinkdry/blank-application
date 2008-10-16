class Article < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  acts_as_item
  acts_as_xapian :texts => [:title, :description, :body]
  	
	has_many :article_files, :dependent => :delete_all
	
	validates_presence_of	:title, :user
                                                   
	def new_file_attributes= file_attributes
	  file_attributes.each do |file_path| 
      article_files.build(:article_id => self.id, :file_path => file_path) 
    end
  end
	
	def self.label
	  "Article"           
  end
end

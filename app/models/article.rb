class Article < ActiveRecord::Base
	
  acts_as_item
  
	belongs_to :user
	
	has_many :article_files, :dependent => :delete_all
	has_many :article_images, :dependent => :delete_all
	
	validates_presence_of	:title,
		:description,
		:introduction,
		:body,
		:conclusion,
		:user
		
	def new_file_attributes= file_attributes
	  file_attributes.each do |attributes| 
      article_files.build(attributes) 
    end
  end
	
	def accepts_role? role, user
	  begin
	    return true if role == 'author' && self.user == user
  	  false
	  rescue Exception => e
	    p e
	    raise e
	  end
  end
end

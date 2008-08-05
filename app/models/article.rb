class Article < ActiveRecord::Base
	
  acts_as_item
  
	belongs_to :user
	
	has_many :artic_files
	has_many :images
	
	validates_presence_of	:title,
		:description,
		:user
		
	def new_file_attributes= file_attributes
	  file_attributes.each do |attributes| 
      articles_artic_files.build(attributes) 
    end
  end
  
  def existing_file_attributes= user_attributes
    articles_artic_files.reject(&:new_record?).each do |uw|
      attributes = user_attributes[uw.id.to_s]
      attributes ? uw.attributes = attributes : users_workspaces.delete(uw)
    end
  end
  
  def save_users_workspaces 
    users_workspaces.each do |uw| 
      uw.save(false) 
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

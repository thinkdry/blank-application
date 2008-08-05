class ArticFile < ActiveRecord::Base
  acts_as_item
  
	has_many :articles
	belongs_to :user
	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path,
		:user
	
	# TODO : sortir	dans act_as_item
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

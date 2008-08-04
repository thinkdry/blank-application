class Video < ActiveRecord::Base
  acts_as_item
  
	belongs_to :users
	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path
end

class Audio < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description]
  	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path,
		:user
         validates_file_format_of :file_path, :in => ["mp3", "wav"]
	
	def self.label
    "Audio"
	end
end

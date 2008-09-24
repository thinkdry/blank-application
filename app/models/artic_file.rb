class ArticFile < ActiveRecord::Base
  acts_as_item
  #acts_as_xapian :texts => [:title, :description]
  	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path,
		:user

  def self.label
    "Fichier"
  end
end

class ArticFile < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :file_path]
  	
	file_column :file_path

  def self.label
    "Fichier"
  end
end

class Publication < ActiveRecord::Base
  acts_as_item
  
  file_column :file_path
  
  def self.label
    "Publication"
  end
end

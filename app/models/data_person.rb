class DataPerson < ActiveRecord::Base
  
  serialize :data
  belongs_to :person
  # Default order for Model
  default_scope :order => 'created_at DESC'
end

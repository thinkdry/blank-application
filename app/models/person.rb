class Person < ActiveRecord::Base
  include Authentication

  has_and_belongs_to_many :groups

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK
  
end

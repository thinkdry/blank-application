require 'regexps'
class Newsletter < ActiveRecord::Base
include Authentication
	acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags]
  has_and_belongs_to_many :groups
  has_many :groups_newsletters

  validates_presence_of     :from_email
  validates_length_of       :from_email,    :within => 6..100
  validates_uniqueness_of   :from_email,    :case_sensitive => false
  validates_format_of       :from_email,    :with => RE_EMAIL_OK

  def self.label
    "Newsletter"
  end

end

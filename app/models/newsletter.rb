require 'regexps'
class Newsletter < ActiveRecord::Base
include Authentication

  # Item specific Library - /lib/acts_as_item
	acts_as_item

  has_and_belongs_to_many :groups

  has_many :groups_newsletters, :dependent => :delete_all

  # Validations
  validates_presence_of     :from_email

  validates_length_of       :from_email,    :within => 6..100

  validates_format_of       :from_email,    :with => RE_EMAIL_OK

end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: newsletters
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  body            :text
#  tags            :string(255)
#  viewed_number   :integer(4)
#  rates_average   :integer(4)
#  comments_number :integer(4)
#  category        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  subject         :string(255)
#  from_email      :string(255)
#

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

  acts_as_xapian :texts => [:title, :description, :keywords_list, :body, :subject]

end

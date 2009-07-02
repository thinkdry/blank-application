# == Schema Information
# Schema version: 20181126085723
#
# Table name: bookmarks
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  feed_source_id  :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  link            :string(1024)
#  enclosures      :string(255)
#  authors         :string(255)
#  date_published  :datetime
#  last_updated    :datetime
#  copyright       :string(255)
#  categories      :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  viewed_number   :integer(4)
#  rates_average   :integer(4)
#  comments_number :integer(4)
#  category        :string(255)
#

class Bookmark < ActiveRecord::Base
  
	# Item specific Library - /lib/acts_as_item
	acts_as_item

end

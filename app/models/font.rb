# == Schema Information
# Schema version: 20181126085723
#
# Table name: fonts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  type       :string(255)
#  weight     :string(255)
#  template   :string(255)     default("current")
#  element_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

# This object is used to store some paramters for CSS management.
#
# It is actually not maintained but we let it for future usage.
class Font < ActiveRecord::Base;end

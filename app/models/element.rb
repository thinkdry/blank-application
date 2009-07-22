# == Schema Information
# Schema version: 20181126085723
#
# Table name: elements
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  bgcolor    :string(255)
#  template   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# This object is used to store some parameters for the CSS management.
#
# It is actually not maintained but we let it for future usage.
class Element < ActiveRecord::Base;end

# == Schema Information
# Schema version: 20181126085723
#
# Table name: groups_newsletters
#
#  id            :integer(4)      not null, primary key
#  newsletter_id :integer(4)
#  group_id      :integer(4)
#  sent_on       :datetime
#

class GroupsNewsletter < ActiveRecord::Base

  belongs_to :group
  
  belongs_to :newsletter
  
end

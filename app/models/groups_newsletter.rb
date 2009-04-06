class GroupsNewsletter < ActiveRecord::Base

  belongs_to :group
  belongs_to :newsletter
end

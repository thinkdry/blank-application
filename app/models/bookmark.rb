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
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#

# This class is defining an item object called 'Bookmark'.
#
# You can use it to create a bookmark, just filling the 'link' field with the url you want to save.
# You have also access to other fields like 'description' in order to give more informations
# to the search engine of the application.
#
# On the show page, a direct link to that url will be present.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Bookmark < ActiveRecord::Base
  
	# Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
	acts_as_item
	# Validation of the presence of the 'link' field
  validates_presence_of :link
  validates_format_of   :link, :with => /#{URL}/ix

  before_save :remove_scripting_tags
  
  # remove script tags like javascript/html tags
  def remove_scripting_tags
    self.copyright = ActionController::Base.helpers.strip_tags(self.copyright)
    self.categories = ActionController::Base.helpers.strip_tags(self.categories)
  end

end

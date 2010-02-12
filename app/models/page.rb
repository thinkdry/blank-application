require 'friendly_url'
class Page < ActiveRecord::Base
  acts_as_item
  
  belongs_to :menu

  def published?
    published
  end
end

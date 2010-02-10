require 'friendly_url'
class Page < ActiveRecord::Base
  acts_as_item
  
  belongs_to :menu

  before_save :set_title_sanitized

  def set_title_sanitized
    self['title_sanitized'] =  self.title.humanize.urlize
  end
  
  def published?
    published
  end
end

require 'friendly_url'
class Page < ActiveRecord::Base
  acts_as_item

  before_save :set_title_sanitized

  def set_title_sanitized
    self['title_sanitized'] =  self.title.humanize.urlize
  end

end

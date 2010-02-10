class Menu < ActiveRecord::Base

  acts_as_tree

  belongs_to :website

  belongs_to :page

  belongs_to :result_set

  validates_uniqueness_of :url, :scope => :website_id

  before_save :set_title_sanitized

  def set_title_sanitized
    self['title_sanitized'] =  self.url.humanize.urlize
  end

end


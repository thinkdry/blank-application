class Menu < ActiveRecord::Base

  acts_as_tree

  belongs_to :website

  belongs_to :page

  belongs_to :result_set

  validates_presence_of :name, :seo_title

  validates_uniqueness_of :seo_title, :scope => :website_id

  before_save :set_title_sanitized

  def set_title_sanitized
    self['title_sanitized'] =  self.seo_title.humanize.urlize
  end

  def title
    seo_title
  end

  def description
    result = []
    result << page.description if page
    result << result_set.description if result_set
    return result.join(',')
  end

  def keywords_list
    result = []
    result << page.keywords_list if page
    result << result_set.keywords if result_set
    return result.join(',')
  end

end


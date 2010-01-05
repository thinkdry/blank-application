class Page < ActiveRecord::Base
  acts_as_item
  
  before_save :set_title_sanitized

  def set_title_sanitized
    self['title_sanitized'] =  self.title.humanize.urlize
  end

  # Check with previously existing page in selected workspaces(associated workspaces)
	#
	# This method checks if the page is uniq in associated workspaces or not.
  def validate
    if !self.associated_workspace_ids.nil?
      self.associated_workspace_ids.each do |w_id|
        conditions = "pages.id != #{self.id} AND" if !self.id.nil?
        if !Workspace.exists?(:id => w_id, :state =>"private") && Page.count_by_sql("SELECT count(*) AS count_all FROM `pages` INNER JOIN `items_workspaces` ON `pages`.id = `items_workspaces`.itemable_id AND `items_workspaces`.itemable_type = 'Page' WHERE ( #{conditions} pages.title_sanitized = '#{self.set_title_sanitized}') AND ((`items_workspaces`.workspace_id = #{w_id}))") > 0
          self.errors.add(:title, :taken)
          return false
        end
      end
    end
  end
end

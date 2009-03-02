# == Schema Information
# Schema version: 20181126085723
#
# Table name: publications
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  feed_source_id :integer(4)
#  title          :string(255)
#  description    :text
#  state          :string(255)
#  link           :string(255)
#  enclosures     :string(255)
#  authors        :string(255)
#  date_published :datetime
#  last_updated   :datetime
#  copyright      :string(255)
#  categories     :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  tags           :string(255)
#

class Publication < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :authors, :file_path],
                 :values => [[:created_at, 0, "created_at", :number], [:title, 1, "title", :string], [:comment_size, 2, "comment_size", :number], [:rate_size, 3, "rate_size", :number]]
  
  file_column :file_path

  def comment_size
    self.comments.size
  end

  def rate_size
    self.rating.to_i
  end

end

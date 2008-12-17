class <%= class_name %> < ActiveRecord::Base

	acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags]

  def self.label
    "<%= class_name %>"
  end

end

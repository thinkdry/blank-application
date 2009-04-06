class Newsletter < ActiveRecord::Base

	acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags]
  has_and_belongs_to_many :groups
  has_many :groups_newsletters
  def self.label
    "Newsletter"
  end

end

require 'friendly_url'
class Page < ActiveRecord::Base
  acts_as_item
  
	# Audit activation of the item
	acts_as_audited :except => :viewed_number

  belongs_to :menu

  def published?
    published
  end
end

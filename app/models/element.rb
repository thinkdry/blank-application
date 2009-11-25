# == Schema Information
# Schema version: 20181126085723
#
# Table name: elements
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  bgcolor    :string(255)
#  template   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# This object is used to store some parameters for the CSS management.
#
# It is actually not maintained but we let it for future usage.
class Element < ActiveRecord::Base

#  named_scope :templates
#  {:select => 'DISTINCT template}

  named_scope :current,
    {:conditions => {:template => 'current'}}

  named_scope :style_for, lambda { |style|
    {:conditions => {:template => 'current', :name => style}}
  }

  named_scope :template_elements, lambda{|template|
    {:conditions => {:template => template}}
  }

  # Return all distinct templates
  # TODO Use Named_Scope
  def self.templates
    find(:all, :select => 'DISTINCT template')
  end

end

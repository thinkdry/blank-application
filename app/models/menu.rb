class Menu < ActiveRecord::Base

  acts_as_tree

  belongs_to :website

end


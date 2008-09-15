class GenericItem < ActiveRecord::Base
  self.inheritance_column = :item_type
end

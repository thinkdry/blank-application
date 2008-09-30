class Item < ActiveRecord::Base
	
  belongs_to :workspace
  belongs_to :itemable, :polymorphic => true, :include => :user

end

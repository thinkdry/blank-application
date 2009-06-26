class Grouping < ActiveRecord::Base

  belongs_to :group

  belongs_to :groupable, :polymorphic => true

  belongs_to :user,  :class_name => "User", :foreign_key => "groupable_id"

  belongs_to :person,     :class_name => "Person", :foreign_key => "groupable_id"

  
  def member
    self.groupable_type.classify.constantize.find(self.groupable_id)
  end

end

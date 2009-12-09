class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  
  # NOTE: Rating belong to a user
  belongs_to :user
  
  # Helper class method to lookup all ratings assigned
  # to all rateable types for a given user.
  def self.find_ratings_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end

  def self.already_rated?(user,item)
    self.exists?(:rateable_type => item.class.to_s, :rateable_id => item.id, :user_id => user.id)
  end

end
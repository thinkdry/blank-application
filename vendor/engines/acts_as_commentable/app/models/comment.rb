# == Schema Information
# Schema version: 20181126085723
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  text             :text
#  user_id          :integer(4)
#  commentable_id   :integer(4)
#  commentable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Comment < ActiveRecord::Base
	
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  has_many :replies, :foreign_key => :parent_id, :class_name => 'Comment', :dependent => :delete_all
  validates_presence_of :text
	
end

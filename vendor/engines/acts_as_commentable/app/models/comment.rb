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

# This class is used to manage the Comment objects.
class Comment < ActiveRecord::Base

	# Relation 1-N to 'users' table
  belongs_to :user
	# Polymorphic relation definition
  belongs_to :commentable, :polymorphic => true
	# Reflective relation on 'comments' table getting the replies for a comment
  has_many :replies, :foreign_key => :parent_id, :class_name => 'Comment', :dependent => :delete_all
	# Validation of the presence of this field
  validates_presence_of :text
	
end

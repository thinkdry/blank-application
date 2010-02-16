# == Schema Information
# Schema version: 20181126085723
#
# Table name: newsletters
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  body            :text
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  subject         :string(255)
#  from_email      :string(255)
#

require 'regexps'

# This class is defining an item object called 'Newsletter'.
#
# You can use it to write a newsletter, adding style, links or images with the FCKeditor.
# After, on the show page, it is possible to send this newsletter to a Group.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Newsletter < ActiveRecord::Base
include Authentication

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
	acts_as_item

	# Audit activation of the item
	acts_as_audited :except => :viewed_number

	# Relation N-N with 'groups' table
  has_and_belongs_to_many :groups
	# Relation N-1 with 'groups_newsletters' table
  has_many :groups_newsletters, :dependent => :delete_all
  # Validation of the presence of body on edition of newsletter
  validates_presence_of :body, :on => :update
  # Validation of the presence of the field passed
  validates_presence_of     :from_email
	# Validation of the size of the field passed
  validates_length_of       :from_email,    :within => 6..100
	# Validation of the format of the field passed
  validates_format_of       :from_email,    :with => RE_EMAIL_OK
	# Overwriting of the ActsAsXapian specification define in ActsAsItem,
	# in order to include the 'body' and 'subject' fields inside the Xapian index
  acts_as_xapian :texts => [:title, :description, :keywords_list, :body, :subject]

end

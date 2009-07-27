# == Schema Information
# Schema version: 20181126085723
#
# Table name: groups
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

# This class is defining an item object called 'Group'.
#
# You can use it to link different email addresses from the current user contacts.
# Thus, it becomes easy to send newsletters to these contacts, or to share these contacts inside a workpace.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Group < ActiveRecord::Base

	# Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
	acts_as_item
	# Relation N-N to 'newsletters' table
  has_and_belongs_to_many :newsletters
	# Relation 1-N 
  has_many :groups_newsletters, :dependent => :delete_all
	# Relation N-1 to the 'groupings' table, defining the object composing the group
  has_many :groupings, :dependent => :delete_all
	# Relation N-1 to the 'groupings' table and scoping the User objects
  has_many :users, :through => :groupings, :source => :user,
    :conditions => "groupings.groupable_type = 'User'", :order => 'email ASC'
	# Relation N-1 to the 'groupings' table and scoping the Person objects
  has_many :people, :through => :groupings, :source => :person,
    :conditions => "groupings.groupable_type = 'Person'", :order => 'email ASC'
  
  # Setting the Grouping objects given as parameters
  # 
  # This method allows to manage directly the objects to link to this group and sent by the form.
	# Depending of the values retrieved from the paramter, it will create or delete Grouping objects.
	# The parameter has to be a array of string following the syntax :
	# - (object_name)_(object_id)
	#
	# Usage :
	# - @group.groupable_objects= ['User_1', 'Person_23', .... ]
  def groupable_objects= params 
    tmp = []
    params.split(',').each do |option|
      tmp << option.split('_')[0].classify.constantize.find(option.split('_')[1])
    end
    self.groupings.each do |k|
      self.send(k.groupable_type.underscore.pluralize).delete(k.member) unless tmp.delete(k.member)
    end
    tmp.each do |obj|
      self.groupings << groupings.build(:group_id => self.id, :groupable_id => obj.id,:groupable_type =>obj.class.to_s)
    end
  end

  # List of the objects composing the Group, ordered by email
	#
	# This method will return a list of the objects composing the group,
	# converted with the 'to_people' method in order to be able to order the list properly.
	# By the way, it will allow to manage this list in a generic way.
  def members
    (self.users + self.people).map{ |e| e.to_people }.sort! { |a,b| a.email.downcase <=> b.email.downcase }
  end

end

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
#  tags            :string(255)
#  viewed_number   :integer(4)
#  rates_average   :integer(4)
#  comments_number :integer(4)
#  category        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Group < ActiveRecord::Base

  has_and_belongs_to_many :newsletters

  has_many :groups_newsletters, :dependent => :delete_all

  has_many :groupings, :dependent => :delete_all

  has_many :users, :through => :groupings, :source => :user,
    :conditions => "groupings.groupable_type = 'User'", :order => 'email ASC'

  has_many :people,    :through => :groupings, :source => :person,
    :conditions => "groupings.groupable_type = 'Person'", :order => 'email ASC'

	acts_as_item
  
  def self.label
    "Group"
  end

  # Store the Group Objects and Check If the Member Exists Previously in the Group
  # 
  # params are selected_Option from View
  def groupable_objects= params #selected_Option : "class_id","class_id"...
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

  # Sorting Members(People and Users) According to Email
  def members
    (self.users + self.people).map{ |e| e.to_people }.sort! { |a,b| a.email.downcase <=> b.email.downcase }
  end

end

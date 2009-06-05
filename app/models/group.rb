class Group < ActiveRecord::Base

  has_and_belongs_to_many :newsletters
  has_many :groups_newsletters, :dependent => :delete_all

  has_many :groupings, :dependent => :delete_all
  has_many :users, :through => :groupings, :source => :user,
    :conditions => "groupings.groupable_type = 'User'", :order => 'email ASC'
  has_many :people,    :through => :groupings, :source => :person,
    :conditions => "groupings.groupable_type = 'Person'", :order => 'email ASC'



	acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags]

  validates_presence_of     :title
  
  def self.label
    "Group"
  end


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

  def members
    (self.users + self.people).map{ |e| e.to_people }.sort! { |a,b| a.email.downcase <=> b.email.downcase }
  end

end

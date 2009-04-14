class Group < ActiveRecord::Base

  has_and_belongs_to_many :newsletters
  has_many :groups_newsletters

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

   def group_people(groupable_ids,current_user)
    groupable_ids = groupable_ids.split(',')
    groupable_ids.each do |groupable_id|
      if Grouping.find(:first,:conditions=>{:group_id => self.id, :groupable_id => groupable_id.split('_')[1].to_i,:groupable_type =>groupable_id.split('_')[0].capitalize,:user_id => current_user.id}).nil?
        self.groupings <<  groupings.build(:group_id => self.id, :groupable_id => groupable_id.split('_')[1].to_i,:groupable_type =>groupable_id.split('_')[0].capitalize,:user_id => current_user.id)
      end
    end
    for g in self.groupings
        Grouping.delete_all(["groupable_type = '"+g.groupable_type+"' and groupable_id = "+ g.groupable_id.to_s+' and user_id ='+current_user.id.to_s]) if !groupable_ids.include?(g.groupable_type.downcase+'_'+g.groupable_id.to_s)
    end
  end

  def members
    (self.users + self.people).sort! { |a,b| a.email.downcase <=> b.email.downcase }
  end

  def self.members_to_subscribe(alpha)
    (Person.find(:all,:conditions=>["email REGEXP ?","^([#{alpha}])"]) + User.find(:all,:conditions=>["email REGEXP ? and newsletter = true","^([#{alpha}])"])).sort! { |a,b| a.email.downcase <=> b.email.downcase }
  end

end

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

  def self.members_to_subscribe(alpha, user = nil)
    if !user.nil?
      people = Person.find(:all,:conditions=>["email REGEXP ? and user_id = ?","^([#{alpha}])",user.id])
      users = []
      people_email_ids = people.map{|p| "'"+p.email+"'"}
      !people_email_ids.empty? ? email_id_filter = " AND u.email NOT IN (#{people_email_ids.join(',')})" : ''
      Workspace.allowed_user_with_permission(user.id,'group_edit').each do |ws|
#        users << User.find_by_sql("SELECT * FROM users u INNER JOIN users_workspaces ON u.id = users_workspaces.user_id    WHERE ((u.email REGEXP '^([#{alpha}])' AND newsletter = true#{email_id_filter} ) AND (users_workspaces.workspace_id = #{ws.id})) ")
          users << User.find_by_sql("SELECT * FROM users u WHERE u.id IN (SELECT user_id FROM users_workspaces WHERE workspace_id = #{ws.id}) AND u.email REGEXP '^([#{alpha}])' AND newsletter = true#{email_id_filter} ")
      end
      return (people + users.flatten.uniq).sort!{ |a,b| a.email.downcase <=> b.email.downcase }
    else
      []
    end
  end

  def self.user_to_people(user)
    return Person.new(:first_name => user.firstname,:last_name => user.lastname,:email => user.email,
      :primary_phone => user.phone,:mobile_phone => user.mobile,:city => user.address,
      :country => user.nationality,:company => user.company,:job_title => user.activity,
      :newsletter => user.newsletter,:created_at => user.created_at,:updated_at => user.updated_at)
  end
end

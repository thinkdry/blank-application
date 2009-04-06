class Group < ActiveRecord::Base

  has_and_belongs_to_many :people
  has_many :groups_people
  has_and_belongs_to_many :newsletters
  has_many :groups_newsletters

  validates_presence_of     :title

  def group_people= people_ids
    people_ids = people_ids.split(',')
    people_ids.each do |person_id|
      if GroupsPerson.find(:first,:conditions=>{:person_id => person_id, :group_id => self.id}).nil?
        self.groups_people <<  groups_people.build(:group_id => self.id, :person_id => person_id)
      end
    end
    for g_p in self.groups_people
        g_p.destroy if !people_ids.include?(g_p.person_id.to_s)
    end
  end

end

class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces, :dependent => :delete_all
	has_many :roles, :through => :users_workspaces
	has_many :users, :through => :users_workspaces
	has_many :items, :dependent => :delete_all
  has_many_polymorphs :itemables, :from => [:articles, :artic_files, :audios, :videos, :images, :publications], :through => :items
	belongs_to :creator, :class_name => 'User'
	
	validates_presence_of :name
	validates_associated  :users_workspaces
	validate  :uniqueness_of_users
	
	after_update  :save_users_workspaces
	
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
	
	named_scope :administrated_by, lambda { |user|
	  raise 'User required' unless user
	  { :conditions => "creator_id = #{user.id}" }
  }
  
  named_scope :consulted_by, lambda { |user|
    raise 'User required' unless user
    { :include => [ :users_workspaces ],
      :conditions => "users_workspaces.user_id = #{user.id}" }
  }
  
  named_scope :by_user_and_role, lambda { |user, role|
    raise 'Args missing' if user.nil? || role.nil?
    { :include => [ :users_workspaces, :roles ],
      :conditions => "users_workspaces.user_id = #{user.id} AND roles.name = '#{role}'" }
  }
  
  def self.moderated_by user
    self.by_user_and_role(user, 'Modérateur')
	end
	
	def self.with_moderator_role_for user
	  self.moderated_by user
  end
	
	def self.with_writter_role_for user
	  self.by_user_and_role(user, 'Rédacteur')
	end
	
	def self.with_reader_role_for user
	  self.by_user_and_role(user, 'Lecteur')
	end
	
	def uniqueness_of_users
	  new_users = self.users_workspaces.reject { |e| ! e.new_record? }.collect { |e| e.user }
	  new_users.size.times do
		  self.errors.add_to_base('Same user added twice') and return if new_users.include?(new_users.pop)
	  end
  end
	
	def users_by_role role_name
	  role = self.roles.find_by_name(role_name)
	  role ? role.users : []
  end
  
	def moderators
	  users_by_role('Modérateur')
  end
  
	def writters
	  users_by_role('Rédacteur')
  end
  
	def readers
	  users_by_role('Lecteur')
  end
	
	def new_user_attributes= user_attributes
	  #downcase_user_attributes(user_attributes)
	  user_attributes.each do |attributes| 
      users_workspaces.build(attributes) 
    end
  end
  
  def existing_user_attributes= user_attributes
   #downcase_user_attributes(user_attributes)
    users_workspaces.reject(&:new_record?).each do |uw|
      attributes = user_attributes[uw.id.to_s]
      attributes ? uw.attributes = attributes : users_workspaces.delete(uw)
    end
  end
  
  def save_users_workspaces 
    users_workspaces.each do |uw| 
      uw.save(false) 
    end 
  end 
  
  def accepts_role? role, user
    return true if role == 'member' && user.all_workspaces.include?(self)
    false
  end
  
  private
  def downcase_user_attributes(attributes)
    attributes.each { |value| value['user_login'].downcase! }
  end
end

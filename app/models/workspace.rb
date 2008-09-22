class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces, :dependent => :delete_all
	has_many :users, :through => :users_workspaces
	has_many :items, :dependent => :delete_all
  has_many_polymorphs :itemables, :from => [:articles, :artic_files, :audios, :videos, :images, :publications], :through => :items
	
	validates_presence_of :name
	validates_associated  :users_workspaces
	validate  :uniqueness_of_users
	
	after_update  :save_users_workspaces
	
	belongs_to :creator, :class_name => 'User'
	
	def latest_comments
	  Comment.all(:order => 'created_at DESC').select { |c| c.commentable.workspace_ids.include?(self.id) }[0..5]
  end
	
	def uniqueness_of_users
	  new_users = self.users_workspaces.reject { |e| ! e.new_record? }.collect { |e| e.user }
	  new_users.size.times do
		  self.errors.add_to_base('Same user added twice') and return if new_users.include?(new_users.pop)
	  end
  end
	
	def new_user_attributes= user_attributes
	  downcase_user_attributes(user_attributes)
	  user_attributes.each do |attributes| 
      users_workspaces.build(attributes) 
    end
  end
  
  def existing_user_attributes= user_attributes
    downcase_user_attributes(user_attributes)
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
	
	def usersByRole(role_name)
		@result = []
		UsersWorkspace.find(:all, :conditions => { :workspace_id => self.id, :role_id => Role.find_by_name(role_name).id }).each do |uw|
			@result << User.find(uw.user_id)
		end
		return @result
  end
	
  
  private
  def downcase_user_attributes(attributes)
    attributes.each { |value| value['user_login'].downcase! }
  end
	
	
	
end

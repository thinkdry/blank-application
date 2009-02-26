# == Schema Information
# Schema version: 20181126085723
#
# Table name: workspaces
#
#  id          :integer(4)      not null, primary key
#  creator_id  :integer(4)
#  description :text
#  title       :string(255)
#  state       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces, :dependent => :delete_all
	has_many :roles, :through => :users_workspaces
	has_many :users, :through => :users_workspaces
	has_many :items, :dependent => :delete_all
  has_many_polymorphs :itemables, :from => ITEMS.map{ |item| item.pluralize.to_sym }, :through => :items
	has_many :feed_items, :through => :feed_sources
	belongs_to :creator, :class_name => 'User'
	belongs_to :ws_config
	
	validates_presence_of :title
	validates_associated :users_workspaces
	validate :uniqueness_of_users
	
	after_update  :save_users_workspaces
	
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
  
  # Must be called from User.
  # Example : User.first.workspaces.moderated
  named_scope :moderated, {
    :include => [ :roles ],
    :conditions => "roles.name = 'moderator'"
  }
  
  # Must be called from User.
  # Example : User.first.workspaces.written
  named_scope :written, {
    :include => [ :roles ],
    :conditions => "roles.name = 'writer'"
  }
  
  # Must be called from User.
  # Example : User.first.workspaces.read
  named_scope :read, {
    :include => [ :roles ],
    :conditions => "roles.name = 'reader'"
  }
	
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
    self.by_user_and_role(user, 'moderator')
	end
	
	def self.with_moderator_role_for user
	  self.moderated_by user
  end
	
	def self.with_writter_role_for user
	  self.by_user_and_role(user, 'writer')
	end
	
	def self.with_reader_role_for user
	  self.by_user_and_role(user, 'reader')
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
	  users_by_role('moderator')
  end
  
	def writters
	  users_by_role('writer')
  end
  
	def readers
	  users_by_role('reader')
  end
	
	# Link the attributes directly from the form
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

	def accepts_show_for? user
		return accepting_action(user, 'show', (self.creator_id==user.id), false, true)
	end

  def accepts_destroy_for? user
    return accepting_action(user, 'edit', (self.creator_id==user.id), false, true)
  end

  def accepts_edit_for? user
    return accepting_action(user, 'edit', (self.creator_id==user.id), false, true)
  end

  def accepts_new_for? user
    return accepting_action(user, 'new', false, false, true)
  end

	private
	def accepting_action(user, action, spe_cond, sys_cond, ws_cond)
				 # Special access
				if user.is_superadmin? || spe_cond
					return true
				end
        # System access
				if user.has_system_permission(self.class.to_s.downcase, action) || sys_cond
					return true
				end
        # Workspace access
				# Not for new and index normally ...
				if self.users.include?(user)
					if user.has_workspace_permission(self.id, self.class.to_s.downcase, action) && ws_cond
						return true
					end
				end
			  false
	end

  private
  def downcase_user_attributes(attributes)
    attributes.each { |value| value['user_login'].downcase! }
  end
  
end

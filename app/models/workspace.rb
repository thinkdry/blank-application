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

	has_attached_file :logo,
    :url =>  "/uploaded_files/workspace/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/workspace/:id/:style/:basename.:extension",
		:styles => { :medium => "300x300>", :thumb => "48x48>" }
  validates_attachment_content_type :logo, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp' ]
  validates_attachment_size :logo, :less_than => 2.megabytes
	
	validates_presence_of :title, :description
	validates_associated :users_workspaces
	validate :uniqueness_of_users
	
	after_update  :save_users_workspaces
	
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5

	named_scope :allowed_user_with_permission, lambda { |user_id, permission_name|
		raise 'User required' unless user_id
		raise 'Permission name' unless permission_name
		if User.find(user_id).has_system_role('superadmin')
			{ }
		else
			{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user_id.to_i} "+
						"LEFT JOIN permissions_roles ON permissions_roles.role_id = users_workspaces.role_id "+
						"LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id",
				:conditions => "permissions.name = '#{permission_name.to_s}'" }
		end
	}

	named_scope :allowed_user_with_ws_role, lambda { |user_id, role_name|
		raise 'User required' unless user_id
		raise 'Role name' unless role_name
		{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user_id.to_i} "+
					"LEFT JOIN roles ON roles.id = users_workspaces.role_id",
			:conditions => "roles.name = '#{role_name.to_s}'" }
	}

	def uniqueness_of_users
	  new_users = self.users_workspaces.reject { |e| ! e.new_record? }.collect { |e| e.user }
	  new_users.size.times do
		  self.errors.add_to_base('Same user added twice') and return if new_users.include?(new_users.pop)
	  end
  end
	
	def users_by_role role_name
	  role = self.roles.find_by_name(role_name)
	  res = []
		if role
			uw = UsersWorkspace.find(:all, :conditions => { :role_id => role.id, :workspace_id => self.id })
			uw.each do |e|
				res << e.user
			end
		end
		return res
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
				if user.has_system_role('superadmin') || spe_cond
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

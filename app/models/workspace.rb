# == Schema Information
# Schema version: 20181126085723
#
# Table name: workspaces
#
#  id                 :integer(4)      not null, primary key
#  creator_id         :integer(4)
#  description        :text
#  title              :string(255)
#  state              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  ws_items           :string(255)     default("")
#  ws_item_categories :string(255)     default("")
#  logo_file_name     :string(255)
#  logo_content_type  :string(255)
#  logo_file_size     :integer(4)
#  ws_available_types :string(255)     default("")
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

	acts_as_xapian :texts => [:title, :description]

  # Paperclip Attachment
	has_attached_file :logo,
    :default_url => "/images/logo.png",
    :url =>  "/uploaded_files/workspace/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/workspace/:id/:style/:basename.:extension",
		:styles => { :medium => "450x100>", :thumb => "48x48>" }

  # Paperclip Validations
  validates_attachment_content_type :logo, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp' ]

  validates_attachment_size :logo, :less_than => 2.megabytes

  # Validations

	validates_presence_of :title, :description

	validates_associated :users_workspaces

	validate :uniqueness_of_users

	# After Updation Save the associated Users in UserWorkspaces
	after_update  :save_users_workspaces

  # Latest 5 workspaces
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5

  # Get the Users for the workspace with allowed permission
	named_scope :allowed_user_with_permission, lambda { |user_id, permission_name|
		raise 'User required' unless user_id
		raise 'Permission name' unless permission_name
		if User.find(user_id).has_system_role('superadmin')
			{ :order => "workspaces.title ASC" }
		else
			{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user_id.to_i} "+
          "LEFT JOIN permissions_roles ON permissions_roles.role_id = users_workspaces.role_id "+
          "LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id",
				:conditions => "permissions.name = '#{permission_name.to_s}'" ,
        :order => "workspaces.title ASC"
      }
		end
	}

  # Get the Workspace for the Users with given Role
	named_scope :allowed_user_with_ws_role, lambda { |user_id, role_name|
		raise 'User required' unless user_id
		raise 'Role name' unless role_name
		{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user_id.to_i} "+
        "LEFT JOIN roles ON roles.id = users_workspaces.role_id",
			:conditions => "roles.name = '#{role_name.to_s}'" }
	}

  # Unique User for UserWorkspace after Worksapce Update
	def uniqueness_of_users
	  new_users = self.users_workspaces.collect { |e| e.user }
	  new_users.size.times do
		  self.errors.add_to_base('Same user added twice') and return if new_users.include?(new_users.pop)
	  end
  end

  # Users of the worksapce with the defined Roles
  #
  # Usage:
  #
  # <tt>workspace.users_by_role('ws_admin')</tt>
  #
  # will return all the users associated with the workspace with role 'ws_admin'
  #
  # Parameters:
  #
  # - role_name: ws_admin, moderator, writer, reader
	def users_by_role role_name
	  role = self.roles.find_by_name(role_name)
	  res = []
		if role
			# TODO find_by_mysql
			uw = UsersWorkspace.find(:all, :conditions => { :role_id => role.id, :workspace_id => self.id })
			uw.each do |e|
				res << e.user
			end
		end
		return res
  end

  # Item Types for the Workspace Joined By ','
	def ws_items= params
		self[:ws_items] = params.join(',')
	end

  # Category for the Workspace Joined By ','
	def ws_item_categories= params
		self[:ws_item_categories] = params.join(',')
	end

  # Available Worksapce Types for Worksapce
	def ws_available_types= params
		self[:available_types] = params.join(',')
	end
	
	# Link the attributesof Users directly
	def new_user_attributes= user_attributes
	  #downcase_user_attributes(user_attributes)
	  user_attributes.each do |attributes| 
      users_workspaces.build(attributes) 
    end
  end

  # Check if the User is Associated with worksapce or not
  def existing_user_attributes= user_attributes
    #downcase_user_attributes(user_attributes)
    users_workspaces.reject(&:new_record?).each do |uw|
      attributes = user_attributes[uw.id.to_s]
      attributes ? uw.attributes = attributes : users_workspaces.delete(uw)
    end
  end

  # Save the workspace assocaitions for Users in UsersWorkspace
  def save_users_workspaces 
    users_workspaces.each do |uw| 
      uw.save(false) 
    end 
  end 

  # Check User for permission to view the Workspace
  #
  # Usage:
  #
  # <tt>workspace.accepts_show_for? user</tt>
  #
  # will return true if the user has permission
	def accepts_show_for? user
		return accepting_action(user, 'show', (self.creator_id==user.id), false, true)
	end

  # Check User for permission to administer the Workspace
  #
  # Usage:
  #
  # <tt>workspace.accepts_administrate_for? user</tt>
  #
  # will return true if the user has permission
	def accepts_administrate_for? user
		return accepting_action(user, 'administrate', (self.creator_id==user.id), false, true)
	end
  # Check User for permission to destroy the Workspace
  #
  # Usage:
  #
  # <tt>workspace.accepts_destroy_for? user</tt>
  #
  # will return true if the user has permission
  def accepts_destroy_for? user
    return accepting_action(user, 'destroy', (self.creator_id==user.id), false, true)
  end

  # Check User for permission to edit the Workspace
  #
  # Usage:
  #
  # <tt>workspace.accepts_edit_for? user</tt>
  #
  # will return true if the user has permission
  def accepts_edit_for? user
    return accepting_action(user, 'edit', (self.creator_id==user.id), false, true)
  end

  # Check User for permission to Create New the Workspace
  #
  # Usage:
  #
  # <tt>workspace.accepts_new_for? user</tt>
  #
  # will return true if the user has permission
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

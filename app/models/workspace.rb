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

# This object deals with the link between users and items.
# Actually, an item is linked to a workspace (through the 'items' table)
# and an user too (through the 'users_workspaces' table, with a specific role).
#
class Workspace < ActiveRecord::Base

	# Relation N-1 with the 'users_workspaces' table
	has_many :users_workspaces, :dependent => :delete_all
	# Relation N-1 getting the roles linked to that workspace, through the 'users_workspaces' table
	has_many :roles, :through => :users_workspaces
	# Relation N-1 getting the users linked to that workspace, through the 'users_workspaces' table
	has_many :users, :through => :users_workspaces
	# Relation N-1 with the 'items' table
	has_many :items, :dependent => :delete_all
	# Relation N-1 getting the different item types, through the 'items' table
	ITEMS.each do |item|
		has_many item.pluralize.to_sym, :source => :itemable, :through => :items, :source_type => item.classify.to_s, :class_name => item.classify.to_s
	end
	# Relation N-1 getting the FeedItem objects, through the 'feed_sources' table
	has_many :feed_items, :through => :feed_sources
	# Relation 1-N to the 'users' table
	belongs_to :creator, :class_name => 'User'

	has_many :contacts_workspaces
	has_many :groups
	# Method defining the attibute to index for the Xapian research
	acts_as_xapian :texts => [:title, :description]

  # Paperclip attachment definition
	has_attached_file :logo,
    :default_url => "/images/logo.png",
    :url =>  "/uploaded_files/workspace/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/workspace/:id/:style/:basename.:extension",
		:styles => { :medium => "450x100>", :thumb => "48x48>" }
  # Validation of the type of a attached file
  validates_attachment_content_type :logo, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp' ]
	# Validation of the size of a attached file
  validates_attachment_size :logo, :less_than => 2.megabytes
	# Validation of the prsence of these fields
	validates_presence_of :title, :description
	#
	validates_associated :users_workspaces
	# Validation of the uniqueness of users associated to that workspace
	validate :uniqueness_of_users
  # Validation of fields not in format of
  validates_not_format_of   :title, :with => /(#{SCRIPTING_TAGS})/
	# After Updation Save the associated Users in UserWorkspaces
	after_update  :save_users_workspaces

  # Scope getting the 5 last workspaces created
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5

  # Scope getting the workspaces authorized for an user with a specific permission
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

  # Scope getting the workspaces authorized for an user with a specific role
	named_scope :allowed_user_with_ws_role, lambda { |user_id, role_name|
		raise 'User required' unless user_id
		raise 'Role name' unless role_name
		{ :joins => "LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{user_id.to_i} "+
        "LEFT JOIN roles ON roles.id = users_workspaces.role_id",
			:conditions => "roles.name = '#{role_name.to_s}'" }
	}

  # Method used for the validation of the uniqueness of users linked to the workspace
	def uniqueness_of_users #:nodoc:
	  new_users = self.users_workspaces.collect { |e| e.user }
	  new_users.size.times do
		  self.errors.add_to_base('Same user added twice') and return if new_users.include?(new_users.pop)
	  end
  end

  # Users of the workspace with the defined role
  #
	# This method retrieves the users of the given role in that workspace.
	#
  # Usage :
  # <tt>workspace.users_by_role('ws_admin')</tt>
  #
  # Parameters :
  # - role_name: String defining the role name (ex : 'superadmin', 'reader', ...)
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

  # Method setting the item types available for that workspace
	#
	# This method will convert the Array given in parameters in an String, where
	# the different elements of this array are joined by ','.
	#
	# Parameters :
	# - params: Array of Strings defining the item types
	def ws_items= params
		self[:ws_items] = params.join(',')
	end

  # Method setting the item categories available for that workspace
	#
	# This method will convert the Array given in parameters in an String, where
	# the different elements of this array are joined by ','.
	#
	# Parameters :
	# - params: Array of Strings defining the item categories
	def ws_item_categories= params
		self[:ws_item_categories] = params.join(',')
	end

  # Method setting the available types available for that workspace
	#
	# This method will convert the Array given in parameters in an String, where
	# the different elements of this array are joined by ','.
	#
	# Parameters :
	# - params: Array of Strings defining the available types
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
  # Usage :
  # <tt>workspace.accepts_show_for?(user)</tt>
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

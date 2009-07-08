# == Schema Information
# Schema version: 20181126085723
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)
#  firstname                 :string(255)
#  lastname                  :string(255)
#  email                     :string(255)
#  address                   :string(500)
#  company                   :string(255)
#  phone                     :string(255)
#  mobile                    :string(255)
#  activity                  :string(255)
#  nationality               :string(255)
#  edito                     :text
#  avatar_file_name          :string(255)
#  avatar_content_type       :string(255)
#  avatar_file_size          :integer(4)
#  avatar_updated_at         :datetime
#  crypted_password          :string(40)
#  salt                      :string(40)
#  activation_code           :string(40)
#  activated_at              :datetime
#  password_reset_code       :string(40)
#  system_role_id            :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  newsletter                :boolean(1)
#  last_connected_at         :datetime
#  u_layout                  :string(255)
#  u_per_page                :integer(4)
#  u_language                :string(255)
#  date_of_birth             :date
#  gender                    :string(255)
#

require 'digest/sha1'
require 'regexps'
require 'country_select'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
	include Configuration

  has_many :users_workspaces, :dependent => :delete_all

  has_many :workspaces, :through => :users_workspaces

  has_many :workspace_roles, :through => :users_workspaces, :source => :role

	ITEMS.each do |item|
		has_many item.pluralize.to_sym
	end

  has_many :rattings

  has_many :comments

  has_many :feed_items, :through => :feed_sources, :order => "last_updated DESC"

  has_many :groupings, :as => :groupable, :dependent => :delete_all

  has_many :member_in, :through => :groupings, :source => :group

  has_many :people, :order => 'email ASC'

	acts_as_xapian :texts => [:login, :firstname, :lastname]

  # Paperclip attachment for avatar
  has_attached_file :avatar,
    :default_url => "/images/default_avatar.png",
    :url =>  "/uploaded_files/user/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/user/:id/:style/:basename.:extension",
    :styles => {
    :thumb=> "100x200>"}
  
  # Paperclip Validations
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
  validates_attachment_size(:avatar, :less_than => 5.megabytes)

  # Validations
  validates_presence_of     :login

  validates_length_of       :login,     :within => 3..40

  validates_uniqueness_of   :login,     :case_sensitive => false, :on => :create

  validates_format_of       :login,     :with => /\A[a-z_-]+\z/

  validates_presence_of     :email

  validates_length_of       :email,    :within => 6..100

  validates_uniqueness_of   :email,    :case_sensitive => false, :on => :create

  validates_format_of       :email,    :with => RE_EMAIL_OK

	validates_presence_of     :password, :on => :create

	validates_presence_of     :password_confirmation, :on => :create

	validates_confirmation_of :password, :on => :create

  validates_presence_of     :firstname, :lastname

  validates_format_of       :firstname, :lastname, :company, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/, :allow_blank => true
			  
  validates_format_of       :address, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL}|#{NUM})+\Z/, :allow_blank => true
  
  validates_format_of       :phone,  :mobile, :with => /\A(#{NUM}){10}\Z/, :allow_blank => true
  

  # Encrypt the password before storing in the database
	before_save :encrypt_password

  # Create the activation code before creating the user for email activation
  before_create :make_activation_code

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :address, :company, :phone, :mobile, :activity, :nationality,:edito, :avatar, :newsletter, :system_role_id, :last_connected_at, :u_layout, :u_language, :u_per_page, :date_of_birth, :gender

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #

  # latest 5 users
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
  
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  #TODO check for duplicate email in the user query, and duplicate emails between users email and people emails (refer blank_application_backup_code in public/)

  # Contact List for the User with desired output format for newsletter
	def get_contacts_list(restriction, output_format, newsletter)
		people = []
		users = []
		conditions = {}
		if newsletter
			conditions.merge!({:newsletter => true})
		end
		if self.has_system_role('superadmin')
			people = Person.all(:conditions => conditions) if restriction == 'all' || restriction == 'people'
			users = User.all(:conditions => {:newsletter => true}) if restriction == 'all' || restriction == 'users'
		else
			if restriction == 'all' || restriction == 'people'
				people = self.people.all(:conditions => conditions)
			end
			if restriction == 'all' || restriction == 'users'
				Workspace.allowed_user_with_permission(self.id,'group_edit').each do |ws|
          users += ws.users.all(:conditions => conditions)#.delete_if{ |e| !e.newsletter }
				end
			end
		end
		if output_format
			return (people + users.uniq).map{ |e| e.send("to_#{output_format}".to_sym) }.sort!{ |a,b| a[:email].downcase <=> b[:email].downcase }
		else
			return (people + users.uniq).sort!{ |a,b| a[:email].downcase <=> b[:email].downcase }
		end
	end

  # User as people for newsletter subscription
  def to_people
    return Person.new(:first_name => self.firstname, :last_name => self.lastname,:email => self.email,
      :primary_phone => self.phone, :mobile_phone => self.mobile,:city => self.address,
      :country => self.nationality,:company => self.company,:job_title => self.activity,
      :newsletter => self.newsletter,:created_at => self.created_at,:updated_at => self.updated_at)
  end

  # User as a Group Member
  def to_group_member
    return { :model => 'User', :id => self.id, :email => self.email, :first_name => self.firstname, :last_name => self.lastname, :origin => 'user registred', :created_at => self.created_at, :newsletter => self.newsletter }
  end


  # Display Name of User(login)
	def display_name
    login
	end

  # Check if User Currently Online
	def currently_online
    true
	end 

  # User System Role for Permissions
  # 
  # Usage:
  #
  # <tt>user.system_role</tt>
  #
  # will return the role object of the system role
  #
	def system_role
		return Role.find(self.system_role_id)
	end

  # Check User for System role with passed 'role'
  # 
  # Usage:
  # 
  # <tt>user.has_system_role('admin')</tt>
  # 
  # will return true if the user has role 'admin' or if he is superadmin
  #
	def has_system_role(role_name)
		return (self.system_role.name == role_name) || self.system_role.name == 'superadmin'
	end

  # Check User for Workspace Role with passed 'workspace' & 'role_type'
  #
  # Usage:
  #
  # <tt>user.has_workspace_role('ws_admin')</tt>
  #
  # will return true if the user has role 'ws_admin' for workspace or if he is superadmin
  #
	def has_workspace_role(workspace_id, role_name)
		return UsersWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id, :role_id => Role.find_by_name(role_name).id) || self.system_role.name == 'superadmin'
	end

  # Users System Permissions
  #
  # Usage:
  #
  # <tt>user.system_permissions</tt>
  #
  # will return all the permissions for the user system role
  #
	def system_permissions
		return self.system_role.permissions
	end

  # Users Workspace Permissions
  # Users System Permissions
  #
  # Usage:
  #
  # <tt>user.workspace_permissions</tt>
  #
  # will return all the permissions for the user workspace role for given workspace
  #
	def workspace_permissions(workspace_id)
		if UsersWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id)
			return UsersWorkspace.find(:first, :conditions => {:user_id => self.id, :workspace_id => workspace_id}).role.permissions
		else
			return []
		end
	end

  # User System Role for Controller and Action
  #
  # Usage:
  #
  # <tt>user.has_system_permission('workspaces','new')</tt>
  #
  # will return true if the user has system permission to create new workspace
  #
	def has_system_permission(controller, action)
		permission_name = controller+'_'+action
		return !self.system_permissions.delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
	end

  # User Worksapce Role for Given Worksapce, Controller and Action
  #
  # Usage:
  #
  # <tt>user.has_workspace_permission('articles','new')</tt>
  #
  # will return true if the user has workspace permission to create new article
  #
	def has_workspace_permission(workspace_id, controller, action)
		permission_name = controller+'_'+action
		return !self.workspace_permissions(workspace_id).delete_if{ |e| e.name != permission_name}.blank? || self.has_system_role('superadmin')
	end


  # Check User for permission to configure
  #
  # Usage:
  #
  # <tt>user.accepts_configure_for? user</tt>
  #
  # will return true if the user has permission
	def accepts_configure_for? user
		return accepting_action(user, 'configure', false, false, true)
	end

  # Check User for permission to View
  #
  # Usage:
  #
  # <tt>user.accepts_show_for? user</tt>
  #
  # will return true if the user has permission
	def accepts_show_for? user
		return accepting_action(user, 'show', (self.id==user.id), false, true)
	end

  # Check User for permission to destroy
  #
  # Usage:
  #
  # <tt>user.accepts_destroy_for? user</tt>
  #
  # will return true if the user has permission
  def accepts_destroy_for? user
    return accepting_action(user, 'edit', (self.id==user.id), false, true)
  end

  # Check User for permission to edit
  #
  # Usage:
  #
  # <tt>user.accepts_edit_for? user</tt>
  #
  # will return true if the user has permission
  def accepts_edit_for? user
    return accepting_action(user, 'edit', (self.id==user.id), false, true)
  end

  # Check User for permission to create
  #
  # Usage:
  #
  # <tt>user.accepts_new_for? user</tt>
  #
  # will return true if the user has permission
  def accepts_new_for? user
    return accepting_action(user, 'new', false, false, true)
  end

  # User Full Name 'Lastname FirstName'
	def full_name
		return self.lastname.to_s+" "+self.firstname.to_s
  end

  # Create Private worksapce for User on creation called 'Private space of user_login'
	def create_private_workspace
		# Creation of the private workspace for the user
		ws = Workspace.create(:title => "Private space of #{self.login}",
      :description => "Worksapce containing all the content created by #{self.full_name}",
      :creator_id => self.id,
      :ws_items => get_configuration['sa_items'],
      :state => 'private')
		# To assign the 'ws_admin' role to the user in his privte workspace
		UsersWorkspace.create(:user_id => self.id,
      :workspace_id => ws.id,
      :role_id => Role.find_by_name('ws_admin').id)
	end

	# Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Check if User is Active
  # 
  # the existence of an activation code means User has not Activated yet
  def active?
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end
  
  #	# Encrypts some data with the salt.
  #  def self.encrypt(password, salt)
  #    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  #  end
  #
  #  # Encrypts the password with the user salt
  #  def encrypt(password)
  #    self.class.encrypt(password, salt)
  #  end
  #
  #  def authenticated?(password)
  #    crypted_password == encrypt(password)
  #  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

	# To change password
	def recently_reset?
    @reset
  end

  def delete_reset_code
    self.password_reset_code = nil
    save(false)
  end

  def create_reset_code
    @reset = true
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end


  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # Check the User Permission for actions with system and worksapce roles.
  # True if User is 'SuperAdministrator'
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
		# The only permission linked to an user in a workspace is 'show'
		if action=='show'
			self.workspaces.each do |ws|
				if ws.users.include?(user)
					if user.has_workspace_permission(ws.id, self.class.to_s.downcase, action) && ws_cond
						return true
					end
				end
			end
		end
		false
	end
end


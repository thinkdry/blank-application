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
#  salutation                :string(255)
#

require 'digest/sha1'
require 'regexps'
require 'country_select'

# This class is managing the User object, used for authentication inside the Blank application.
# It is linked with the RestfulAuthenticatin plugin which is providing hte authentication system,
# the session management (with the Session object present).
#
class User < ActiveRecord::Base

	# Libraries from RestfulAuthenticatin plugin
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
	# Library provinding access to the Blank application configuration
	include Configuration
	# Relation N-1 with the 'users_workspaces' table
  has_many :users_workspaces, :dependent => :delete_all
	# Relation N-1 getting Workspace objects through the 'users_workspaces' table
  has_many :workspaces, :through => :users_workspaces
	# Relation N-1 with the 'rattings' table
  has_many :ratings
	# Relation N-1 with the 'comments' table
  has_many :comments
	# Relation N-1 getting the FeedItem objects through the 'feed_sources' table
  has_many :feed_items, :through => :feed_sources, :order => "last_updated DESC"
	# Relation N-1 with the polymorphic 'contacts_workspaces' table
  has_many :contacts_workspaces, :as => :contactable, :dependent => :delete_all
	# Relation N-1 with the 'people' table
  has_many :people, :order => 'email ASC'

  has_many :groups 
	# Mixin method use to get this object search (see Searchable:ModelMethods for more)
	acts_as_searchable :full_text_fields => [:login, :firstname, :lastname],
					:conditionnal_attribute => []
	# Mixin method including the methods used for roles and permissions checkings (see Authorized::ModelMethods for more)
	acts_as_authorized
	# Mixin method alloing to make easy search on the model (see Authorizable::ModelMethods for more)
	acts_as_authorizable
  # Paperclip attachment definition for user avatar
  has_attached_file :avatar,
    :default_url => "/images/default_avatar.png",
    :url =>  "/uploaded_files/user/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/user/:id/:style/:basename.:extension",
    :styles => {
    :thumb=> "100x200>"}
  # Validation of the content type of the avatar file
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
  # Validation of the size of the avatar file
	validates_attachment_size(:avatar, :less_than => 5.megabytes)

  # Validationof the presence of these attributes
  validates_presence_of     :login, :email, :firstname, :lastname
	validates_presence_of     :password, :on => :create
	validates_presence_of     :password_confirmation, :on => :create
	# Validation of the confirmation of this attribute
	validates_confirmation_of :password, :on => :create
	# Validation of the uniqueness of these attributes
  validates_uniqueness_of   :login,     :case_sensitive => false, :on => :create
	validates_uniqueness_of   :email,    :case_sensitive => false, :on => :create
	# Validation of the length of these attributes
  validates_length_of       :login,     :within => 3..40
	validates_length_of       :email,    :within => 6..40
	# Validation of the format of these fields
  validates_format_of       :login,    :with => /\A[0-9A-Za-z_-]+\z/
  validates_format_of       :email,    :with => RE_EMAIL_OK
  validates_format_of       :firstname, :lastname, :company, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/, :allow_blank => true
#  validates_format_of       :address, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL}|#{NUM})+\Z/, :allow_blank => true
#  validates_format_of       :phone,  :mobile, :with => /\A(#{NUM}){10}\Z/, :allow_blank => true
  validates_length_of       :phone,  :mobile, :in => 7..20, :allow_blank => true
  validates_format_of       :phone,  :mobile, :with => PHONE, :allow_blank => true
  # Validation of fields not in format of
  validates_not_format_of   :address, :edito, :activity, :with => /(#{SCRIPTING_TAGS})/, :allow_blank => true

  # Encrypt the password before storing in the database
	before_save :encrypt_password
  # Create the activation code before creating the user for email activation
  before_create :make_activation_code
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :address, :company, :phone, :mobile, :activity, :nationality,:edito, :avatar, :system_role_id, :last_connected_at, :u_layout, :u_language, :u_per_page, :date_of_birth, :gender, :salutation

  # will return all contacts of a user(people + subscribed users of current user's workspaces). If workspace passed return contacts(people and subscribed users) of given workspace
  def get_contacts_list(workspace=nil)
    contacts = []
    if workspace
      contacts = ContactsWorkspace.all(:all, :conditions =>["contactable_type ='Person' AND workspace_id=#{workspace.id}"],:group =>'contactable_id').map{|cw| cw.contactable}
      contacts  += ContactsWorkspace.all(:all, :conditions =>["contactable_type ='User' AND workspace_id=#{workspace.id}"],:group =>'contactable_id').map{|cw| cw.contactable.to_person}
    else
      contacts = self.people
      contacts  += ContactsWorkspace.all(:all, :conditions =>["contactable_type ='User' AND workspace_id IN (#{User.first.workspaces.all(:select => 'workspaces.id').map{|u| u.id}.join(',')})"],:group =>'contactable_id').map!{|cw| cw.contactable.to_person}
    end
    return contacts
  end


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
	def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # User as people for newsletter subscription
  def to_person
    return Person.new(:first_name => self.firstname, :last_name => self.lastname,:email => self.email,
      :primary_phone => self.phone, :mobile_phone => self.mobile,:city => self.address,
      :country => self.nationality,:company => self.company,:job_title => self.activity,
      :created_at => self.created_at,:updated_at => self.updated_at,:model_name => "User")
  end

  # Display Name of User(login)
	def display_name
    login
	end

  # Check if User Currently Online
	def currently_online
    true
	end 

  # User Full Name 'Lastname FirstName'
	def full_name
		return self.salutation.to_s + " " + self.lastname.to_s + " " + self.firstname.to_s
  end
  
  def full_name_without_salutation
    return self.lastname.to_s.capitalize + " " + self.firstname.to_s.capitalize
  end

  # Create Private worksapce for User on creation called 'Private space of user_login'
	def create_private_workspace
		# Creation of the private workspace for the user
		ws = Workspace.create(:title => "Private for #{self.login}",
      :description => "Worksapce containing all the content created by #{self.full_name}",
      :creator_id => self.id,
      :ws_items => get_configuration['sa_items'],
      :state => 'private')
		# To assign the 'ws_admin' role to the user in his privte workspace
		UsersWorkspace.create(:user_id => self.id,
      :workspace_id => ws.id,
      :role_id => Role.find_by_name('ws_admin').id)
	end

	# Activate the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = 'unlocked'
    save(false)
  end

	# Lock the user in the database
	def lock
		self.activated_at = nil
    self.activation_code = 'locked'
    save(false)
	end

	# Unlock the user in the database
	def unlock
		self.activated_at = Time.now
    self.activation_code = 'unlocked'
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

end


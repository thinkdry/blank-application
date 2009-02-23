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
#

require 'digest/sha1'
require 'regexps'
require 'country_select'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  acts_as_authorized_user
  acts_as_authorizable

  has_many :users_workspaces, :dependent => :delete_all
  has_many :workspaces, :through => :users_workspaces
  has_many :workspace_roles, :through => :users_workspaces

	ITEMS.each do |item|
		has_many item.pluralize.to_sym
	end

  has_many :rattings
  has_many :comments
  has_many :feed_items, :through => :feed_sources, :order => "last_updated"
  has_attached_file :avatar,
    :default_url => "/images/default_avatar.png",
    :url =>  "/uploaded_files/user/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/user/:id/:style/:basename.:extension",
    :styles => {
    :thumb=> "100x200>"}
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
  validates_attachment_size(:avatar, :less_than => 5.megabytes)
  #file_column :image_path, :magick => {:size => "200x200>"}
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
  validates_attachment_size(:avatar, :less_than => 5.megabytes)


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

  validates_presence_of     :firstname, 
                            :lastname,
                            :address,
                            :company,
                            :phone,
                            :mobile,
                            :activity,
                            :nationality,
														:system_role_id

  validates_format_of       :firstname, 
    :lastname,
    :company,
    :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/
			  
  validates_format_of       :address, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL}|#{NUM})+\Z/
  
  validates_format_of       :phone, 
    :mobile,
    :with => /\A(#{NUM}){10}\Z/
  

	before_save :encrypt_password
  before_create :make_activation_code

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :address, :company, :phone, :mobile, :activity, :nationality,:edito, :avatar

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
  
  def items
		@items = []
		ITEMS.map{ |item| item.pluralize }.each do |item|
			@items + self.send(item)
		end
		@items.sort { |a, b| a.created_at <=> b.created_at }
  end
  
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

	def system_permissions
		return Role.find(self.system_role_id).permissions
	end

	def workspace_permissions(workspace_id)
		if UserWorkspace.exists?(:user_id => self.id, :workspace_id => workspace_id)
			return UserWorkspace.first(:first, :conditions => {:user_id => self.id, :workspace_id => workspace_id}).role.permissions
		else
			return []
		end
	end

	def has_system_permission(controller, action)
		permission_name = controller+'_'+action
		return self.system_permissions.exists?(:name => permission_name)
	end

	def has_worskpace_permission(workspace_id, controller, action)
		permission_name = controller+'_'+action
		return self.workspace_permissions(workspace_id).exists?(:name => permission_name)
	end

	def system_role
		return Role.find(self.system_role_id)
	end
    
  def has_role? role
    return (self.system_role && self.system_role.name.downcase == role.downcase)
  end
  
  def is_admin?
    has_role?('admin') or has_role?('superadmin')
  end
	
	def is_superadmin?
    has_role?('superadmin')
  end
  
  def accepts_role? role, user
    begin
      auth_method = "accepts_#{role.downcase}?"
      return (send(auth_method, user)) if defined?(auth_method)
      raise("Auth method not defined")
    rescue Exception => e
      p(e)
      puts e.backtrace[0..20].join("\n")
      raise
    end
  end
  
  def accepts_deletion? user
    return true if user.is_admin?
    false
  end
  
  def accepts_edition? user
    return true if user.is_admin?
    return true if user == self
    false
  end
  
  def accepts_creation? user
    return true if user.is_admin?
    false
  end
	 
	def full_name
		return self.lastname+" "+self.firstname
  end

	# Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
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

	def create_reset_code
    @reset = true
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end
  
  
	
end

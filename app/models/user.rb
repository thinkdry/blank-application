require 'digest/sha1'
require 'regexps'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

	acts_as_authorized_user
  acts_as_authorizable	

	has_many :users_workspaces, :dependent => :delete_all
	has_many :workspaces, :through => :users_workspaces
	has_many :artic_files
	has_many :audios
	has_many :videos
	has_many :images
	has_many :articles
	has_many :rattings
	has_many :comments
	belongs_to :system_role
  
  file_column :image_path, :magick => {:size => "200x200>"}

  validates_presence_of     :login
  validates_length_of       :login,     :within => 3..40
  validates_uniqueness_of   :login,     :case_sensitive => false
  validates_format_of       :login,     :with => /\A[a-z_-]+\z/,
                                        :message => 'invalide : ne peut comporter que des lettres minuscules.'

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK

  validates_presence_of     :firstname, 
                            :lastname,
                            :addr,
                            :laboratory,
                            :phone,
                            :mobile,
                            :activity

  validates_format_of       :firstname, 
			                      :lastname, 
                  			    :laboratory,  :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/         
			  
  validates_format_of       :addr,        :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL}|#{NUM})+\Z/ 
  
  validates_format_of       :phone, 
                  			    :mobile,      :with => /\A(#{NUM}){10}\Z/
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :addr, :laboratory, :phone, :mobile, :activity, :edito, :image_path_temp, :image_path

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def items
    (self.artic_files +
  	 self.audios      +
  	 self.videos      +
  	 self.images      +
  	 self.articles).sort { |a, b| a.created_at <=> b.created_at }
  end
  
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
    
  def has_role? role
    return (self.system_role && self.system_role.name.downcase == role.downcase)
  end
  
  def accepts_role? role, user
     return(true) if (role == 'owner' && user == self)
     false
   end
	
	def workspaces_administred
	  Workspace.find(:all, :conditions => { :creator_id => self.id })
  end
	
	def workspaces_consulted
	  UsersWorkspace.find(:all, :conditions => { :user_id => self.id })
  end
  
  def all_workspaces
    workspaces_consulted + workspaces_administred
  end
end

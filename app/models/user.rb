require 'digest/sha1'
require 'regexps'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
	
	has_many :users_workspaces, :dependent => :delete_all
	has_many :workspaces, :through => :users_workspaces
	has_many :artic_files
	
  
  file_column :image_path, :magick => {:size => "200x200>"}

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => RE_LOGIN_OK

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
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  protected
    


end

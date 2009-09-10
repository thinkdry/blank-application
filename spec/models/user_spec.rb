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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/authorized_spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/authorizable_spec_helper')

describe User do
  include AuthorizedSpecHelper
  include AuthorizableSpecHelper
  fixtures :roles, :permissions,:permissions_roles, :users, :workspaces, :users_workspaces

  def object
    User.new
  end


  def user_attributes
    {
      :login => 'boss',
      :firstname => 'boss',
      :lastname => 'dupond',
      :password => 'monkey',
      :password_confirmation => 'monkey',
      :email => 'boss@thinkdry.com',
      :address => 'Leonard',
      :phone => 1111111111,
      :mobile => 1111111111,
      :company => 'thinkdry',
      :nationality => 'France',
      :system_role_id => 1
    }
  end

  before(:each) do
    @user = object
  end

  it "should be valid" do
    @user.attributes = user_attributes
    @user.should be_valid
  end

  it "should require login" do
    @user.attributes = user_attributes.except(:login)
    @user.should have(3).error_on(:login)
  end


  it "should require a unique login" do
    @user.attributes = user_attributes
    @user.login = 'luc'
    @user.should have(1).error_on(:login)
  end

  it "should require login greater than 3 characters" do
    @user.attributes = user_attributes
    @user.login = 'lu'
    @user.should have(1).error_on(:login)
  end

  it "should require login less than 40 characters" do
    @user.attributes = user_attributes
    @user.login = 'luctctcychchchchchchchchchchchchchhsjsjsaskakalalssssssssaskoksoskkskslkslklasssssdddsddsdsdsdsldksldl'
    @user.should have(1).error_on(:login)
  end

  it "should require login without special characters" do
    @user.attributes = user_attributes
    @user.login = 'luc.23'
    @user.should have(1).error_on(:login)
  end

  it "should require password" do
    @user.attributes = user_attributes.except(:password)
    @user.should have(5).errors_on(:password)
  end

  it "should require confirmation password" do
    @user.attributes = user_attributes.except(:password_confirmation)
    @user.should have(2).errors_on(:password_confirmation)
  end

  it "should require confirmation password same as password" do
    @user.attributes = user_attributes
    @user.password_confirmation = 'monkey1'
    @user.should have(2).error_on(:password)
  end

  it "should require email" do
    @user.attributes = user_attributes.except(:email)
    @user.should have(4).errors_on(:email)
  end

  it "should require unique email" do
    @user.attributes = user_attributes
    @user.email = 'contact@thinkdry.com'
    @user.should have(1).error_on(:email)
  end

  it "should require email with proper format" do
    @user.attributes = user_attributes
    @user.email = 'luc_23@gmailcom'
    @user.should have(1).error_on(:email)
  end

  it "should require firstname" do
    @user.attributes = user_attributes.except(:firstname)
    @user.should have(1).errors_on(:firstname)
  end

  it "should require firstname to be in valid format" do
    @user.attributes = user_attributes
    @user.firstname = 'boss32'
    @user.should have(1).error_on(:firstname)
  end

  it "should require lastname" do
    @user.attributes = user_attributes.except(:lastname)
    @user.should have(1).errors_on(:lastname)
  end

  it "should require lastname to be in valid format" do
    @user.attributes = user_attributes
    @user.lastname = 'dupond_14'
    @user.should have(1).error_on(:lastname)
  end


  it "should validate format of phone, mobile numbers" do
    @user.attributes = user_attributes
    @user.phone = '111111'
    @user.should have(1).error_on(:phone)
  end

  it "should accept only [jpeg,jpg,png,gif,bmp] formats for avatar" do
    %w(image.jpeg image.jpg image.png image.gif image.bmp).each { |image|
      @user.attributes = user_attributes.merge(:avatar => url_to_attachment_file(image))}
    @user.should be_valid
  end

  describe "associations" do

    it "has many users workspaces" do
      User.reflect_on_association(:users_workspaces).to_hash.should == {
        :macro => :has_many,
        :options => {:dependent=>:delete_all, :extend=>[]},
        :class_name => "UsersWorkspace"
      }
    end

    it "has many workspaces" do
      User.reflect_on_association(:workspaces).to_hash.should == {
        :macro => :has_many,
        :options => {:through => :users_workspaces, :extend=>[]},
        :class_name => "Workspace"
      }
    end

    it "has many workspace roles" do
      User.reflect_on_association(:workspace_roles).to_hash.should == {
        :macro => :has_many,
        :options => {:through => :users_workspaces, :source => :role, :extend=>[]},
        :class_name => "WorkspaceRole"
      }
    end

#    ITEMS.each do |item|
#      it "has many #{item}" do
#        User.reflect_on_association(item.pluralize.to_sym).to_hash.should == {
#          :macro => :has_many,
#          :options => {:extend => []},
#          :class_name => item.camelize
#        }
#      end
#    end

    it "has many ratings" do
      User.reflect_on_association(:rattings).to_hash.should == {
        :macro => :has_many,
        :options => {:extend=>[]},
        :class_name => "Ratting"
      }
    end

    it "has many comments" do
      User.reflect_on_association(:comments).to_hash.should == {
        :macro => :has_many,
        :options => {:extend=>[]},
        :class_name => "Comment"
      }
    end

    it "has many people" do
      User.reflect_on_association(:people).to_hash.should == {
        :macro => :has_many,
        :options => {:order => 'email ASC',:extend=>[]},
        :class_name => "Person"
      }
    end
  end


  describe "methods" do

    it "should return contact list" do
     @user = users(:luc)
     @user.get_contacts_list('all',nil,false).should == Person.all
    end

#    it "should convert users to people" do
#      @user = users(:luc)
#      @user.to_people.class.to_s.should == 'Person'
#    end

    it "should convert user to group member" do
      # Dont know how to implement..... whats d use??
    end

    it "should return system role" do
      @user = users(:luc)
      @user.system_role.should == Role.find(1)
    end

    it "should check system role" do
      @user = users(:albert)
      @user.has_system_role('admin').should == true
    end

    it "should check workspace role" do
      @user = users(:albert)
      @user.has_workspace_role(workspaces(:private_for_albert).id,'ws_admin').should == true
    end

    it "should check system permission"  do
      @user = users(:luc)
      @user.has_system_permission('articles','destroy').should == true
    end

    it "should check workspace permission" do
       @user = users(:mj)
       @user.has_workspace_permission(workspaces(:private_for_luc).id,'articles','new') == true
    end

    it "should return full name" do
      @user = users(:peter)
      @user.full_name.strip.should == 'parker peter'
    end

  end

#  describe "Permissions" do
#
#    it "should allow user with role to view user details"
#
#    it "should not allow users without role to view user details"
#
#    it "should allow user with role to create user"
#
#    it "should not allow users without role to create user"
#
#    it "should allow user with role to edit user"
#
#    it "should not allow users without role to edit user"
#
#    it "should allow user with role to destroy user"
#
#    it "should not allow users without role to destroy user"
#
#
#  end


end


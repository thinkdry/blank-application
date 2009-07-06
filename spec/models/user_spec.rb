require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe User do
  fixtures :roles, :permissions, :users, :workspaces, :users_workspaces

  def user
    User.new
  end


  def user_attributes
    users(:luc)
  end

  before(:each) do
    @user = user
  end

  it "should be valid" do
    @user = user_attributes
    @user.should be_valid
  end

  it "should require login" do
    @user = user_attributes.except(:login)
    @user.should_not be_valid
  end


  it "should require a unique login"

  it "should require login between 3 to 40 characters"

  it "should require login without special characters"

  it "should require email"

  it "should require unique email"

  it "should require email with proper format"

  it "should require firstname, lastname, company,address"

  it "should require phone,mobile"

  it "should accept avatar with valid format"

  describe "associations" do

    it "has many users workspaces"

    it "has many workspaces"

    it "has_many workspace roles"

    ITEMS.each do |item|
      it "has many #{item}"
    end

    it "has many ratings"

    it "has many comments"

    it "has many feed items"

    it "has many groupings"

    it "has many members_in"

    it "has many people"
  end

  describe "should have named scopes" do

   it "workspaces_with_permission"
   
   it "latest"
  end

  describe "methods" do

    it "should return contact list"

    it "should convert users to people"

    it "should convert user to group member"

    it "should return system role"

    it "should check system role"

    it "should check workspace role"

    it "should return user permissions"

    it "should check system permission"

    it "should check workspace permission"

    it "should return full name"

    it "should create private workspace on user creating"
  end

  describe "Permissions" do

    it "should allow user with role to view user details"

    it "should not allow users without role to view user details"

    it "should allow user with role to create user"

    it "should not allow users without role to create user"

    it "should allow user with role to edit user"

    it "should not allow users without role to edit user"

    it "should allow user with role to destroy user"

    it "should not allow users without role to destroy user"


  end


end
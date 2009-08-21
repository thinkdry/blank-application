require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersWorkspace do

  def users_workspace
    UsersWorkspace.new
  end

  def users_workspace_attributes
    {
      :user_id => 20,
      :workspace_id => 1,
      :role_id => 4
    }
  end

   before(:each) do
    @users_workspace = users_workspace
  end

  it "should be valid" do
    @users_workspace.attributes = users_workspace_attributes
    @users_workspace.should be_valid
  end

  it "should require user, workspace, role" do
    @users_workspace.attributes = users_workspace_attributes.except(:user_id, :workspace_id, :role_id)
    @users_workspace.should have(1).error_on(:user_id)
    @users_workspace.should have(1).error_on(:workspace_id)
    @users_workspace.should have(1).error_on(:role_id)
  end

  it "should validate uniqueness of user for given workspace" do
    @users_workspace.attributes = users_workspace_attributes
    @users_workspace.user_id = 1
    @users_workspace.should have(1).error_on(:user_id)
  end

  it "should belong to user" do
    UsersWorkspace.reflect_on_association(:user).to_hash.should == {
      :class_name => 'User',
      :options => {},
      :macro => :belongs_to
    }
  end

  it "should belong to workspace" do
    UsersWorkspace.reflect_on_association(:workspace).to_hash.should == {
      :class_name => 'Workspace',
      :options => {},
      :macro => :belongs_to
    }
  end

  it "should belong to role" do
    UsersWorkspace.reflect_on_association(:role).to_hash.should == {
      :class_name => 'Role',
      :options => {},
      :macro => :belongs_to
    }
  end


end
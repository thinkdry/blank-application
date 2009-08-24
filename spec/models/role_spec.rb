require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  fixtures :roles

  def role
    Role.new
  end

  def role_attributes
    {
      :name => 'killer',
      :description => 'admin',
      :type_role => 'system'
    }
  end
  
  before(:each) do
    @role = role
  end

  it "should be valid" do
    @role.attributes = role_attributes
    @role.should be_valid
  end

  it "should require name, type_role" do
    @role.attributes = role_attributes.except(:name,:type_role)
    @role.should have(1).error_on(:name)
    @role.should have(1).error_on(:type_role)
  end

  it "should have a unique name" do
    @role.attributes = role_attributes
    @role.name = 'ws_admin'
    @role.should have(1).error_on(:name)
  end

  it "has and belong to many permissions" do
    Role.reflect_on_association(:permissions).to_hash.should == {
      :class_name => "Permission",
      :options => {:join_table=>"permissions_roles", :extend=>[]},
      :macro => :has_and_belongs_to_many
    }
  end

  it "has many users workspaces" do
    Role.reflect_on_association(:users_workspaces).to_hash.should == {
      :class_name => "UsersWorkspace",
      :options => {:dependent=>:delete_all, :extend=>[]},
      :macro => :has_many
    }
  end

  it "has many workspaces through users workspaces" do
    Role.reflect_on_association(:workspaces).to_hash.should == {
      :class_name => "Workspace",
      :options => {:through => :users_workspaces, :extend=>[]},
      :macro => :has_many
    }
  end

  it "should have many users through users workspaces" do
    Role.reflect_on_association(:users).to_hash.should == {
      :class_name => "User",
      :options => {:through => :users_workspaces, :extend=>[]},
      :macro => :has_many
    }
  end




end
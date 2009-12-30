require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersContainer do
  fixtures :users_containers
  
  def users_containers
    UsersContainer.new
  end

  def users_containers_attributes
    {
      :containerable_id => 1,
      :containerable_type => 'Workspace',
      :user_id => 21,
      :role_id => 14
    }
  end

   before(:each) do
    @users_containers = users_containers
  end

  it "should be valid" do
    @users_containers.attributes = users_containers_attributes
    @users_containers.should be_valid
  end

  it "should require user, container, role" do
    @users_containers.attributes = users_containers_attributes.except(:user_id, :containerable_id, :containerable_type, :role_id)
    @users_containers.should have(1).error_on(:user_id)
    @users_containers.should have(1).error_on(:containerable_id)
    @users_containers.should have(1).error_on(:containerable_type)
    @users_containers.should have(1).error_on(:role_id)
  end

  it "should validate uniqueness of user for given container" do
    @users_containers.attributes = users_containers_attributes
    @users_containers.user_id = 1
    @users_containers.should have(1).error_on(:user_id)
  end

  it "should belong to user" do
    UsersContainer.reflect_on_association(:user).to_hash.should == {
      :class_name => 'User',
      :options => {},
      :macro => :belongs_to
    }
  end
  
  it "should belong to containerable and be polymorphic" do
    UsersContainer.reflect_on_association(:containerable).to_hash.should == {
      :class_name => 'Containerable',
      :options => {:foreign_type => "containerable_type", :polymorphic=>true },
      :macro => :belongs_to
    }
  end

  it "should belong to role" do
    UsersContainer.reflect_on_association(:role).to_hash.should == {
      :class_name => 'Role',
      :options => {},
      :macro => :belongs_to
    }
  end


end


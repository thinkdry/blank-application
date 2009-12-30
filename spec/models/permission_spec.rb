require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  fixtures :permissions

  def permission
    Permission.new
  end

  def permission_attributes
    {
      :name => 'webworld_show',
      :description => 'System Administrator',
      :type_permission => 'system'
    }
  end

  before(:each) do
    @permission = permission
  end

  it "should be valid" do
    @permission.attributes = permission_attributes
    @permission.should be_valid
  end

  it "should require name, type_permission" do
    @permission.attributes = permission_attributes.except(:name, :type_permission)
    @permission.should have(1).error_on(:name)
    @permission.should have(1).error_on(:type_permission)
  end


  it "should have unique name of permission" do
    @permission.attributes = permission_attributes
    @permission.name = 'workspace_show'
    @permission.should have(1).error_on(:name)
  end

  it "has and belong to many roles" do
    Permission.reflect_on_association(:roles).to_hash.should == {
      :class_name => "Role",
      :options => {:join_table=>"permissions_roles", :extend=>[]},
      :macro => :has_and_belongs_to_many
    }
  end



end

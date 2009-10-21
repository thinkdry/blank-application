require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsWorkspace do
  fixtures :users

  def contacts_workspace
    ContactsWorkspace.new
  end

  def contacts_workspace_attributes
    {
      :contactable_id => users(:luc).id,
      :contactable_type => 'User',
      :workspace_id => 1
    }
  end

  before(:each) do
    @contacts_workspace = contacts_workspace
  end

  it "should belongs to workspace" do
    ContactsWorkspace.reflect_on_association(:workspace).to_hash.should == {
        :class_name => "Workspace",
        :options => {},
        :macro => :belongs_to
      }
  end

  it "should have many groupings" do
    ContactsWorkspace.reflect_on_association(:groupings).to_hash.should == {
      :class_name => 'Grouping',
      :options => {:dependent => :delete_all, :extend=>[]},
      :macro => :has_many
    }
  end

  it "should belong to contactable" do
    ContactsWorkspace.reflect_on_association(:contactable).to_hash.should == {
      :class_name => 'Contactable',
      :options => {:foreign_type=>"contactable_type", :polymorphic => true},
      :macro => :belongs_to
    }
  end

  it "should have method to convert person/user to group member" do
    @contacts_workspace.attributes = contacts_workspace_attributes
    @contacts_workspace.to_group_member.should == {
      "created_at" => nil,
      "contact_id" => 1,
      "contact_type" => "User",
      "id" => nil,
      "last_name" => "skywalker",
      "first_name" => "luc",
      "email" => "contact@thinkdry.com",
      "state" => "subscribed",
      "permission" => nil
      }
  end



end


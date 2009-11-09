require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Grouping do

  def grouping
    Grouping.new
  end

  def grouping_attributes
    {
      :group_id => 1,
      :user_id => 1,
      :contacts_workspace_id => 1
    }
  end

  before(:each) do
    @grouping = grouping
  end

  it "should belong to a group" do
    Grouping.reflect_on_association(:group).to_hash.should == {
      :class_name => 'Group',
      :options => {},
      :macro => :belongs_to
    }
  end

  it "should belong to conatcts workspace" do
    Grouping.reflect_on_association(:contacts_workspace).to_hash.should == {
      :class_name => 'ContactsWorkspace',
      :options => {},
      :macro => :belongs_to
    }
  end

#  it "should return the members of the grouping" do
#    # How to implement???
#    @grouping.attributes = grouping_attributes
#    @grouping.member.should == users(:luc)
#  end

end
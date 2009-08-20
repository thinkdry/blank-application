# == Schema Information
# Schema version: 20181126085723
#
# Table name: groups
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

# Parameters: {"group"=>{"associated_workspaces"=>["1", "2"],
#"title"=>"Group1", "description"=>"Group1"}, "group_id"=>"",
# "start_with"=>"j",
# "selected_Options"=>"Person_2,Person_1",
# "keyword"=>{"value"=>""}}


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  fixtures :people
  
  def group
    Group.new
  end


  def group_attributes
    {
      :title => 'mygroup',
      :description => 'my friends group',
      :user_id => 1,
    }
  end

  before(:each) do
    @group = group
  end

  it "should be valid" do
    @group.attributes = group_attributes
    @group.should be_valid
  end

#  it "should have groupable objects" do
#    # Dont know how to check.....just checked stupidly
#    @group.attributes = group_attributes
#    @group.groupable_objects = "Person_2,Person_1"
#    @group.groupings.last.should == @group.groupings.last
#  end

#  it "should return members" do
#    @group.attributes = item_attributes
#    # Test Through fixtures
#    @group.members.should == []
#  end
  describe "associations" do

    it "has and belongs to many newsletters" do
      Group.reflect_on_association(:newsletters).to_hash.should == {
        :class_name=>"Newsletter",
        :options=>{:join_table=>"groups_newsletters", :extend=>[]},
        :macro=>:has_and_belongs_to_many
      }
    end

    it "has many group newsletters" do
      Group.reflect_on_association(:groups_newsletters).to_hash.should == {
        :class_name => "GroupsNewsletter",
        :options => {:dependent => :delete_all, :extend => []},
        :macro => :has_many
      }
    end

    it "has many groupings" do
      Group.reflect_on_association(:groupings).to_hash.should == {
        :class_name => "Grouping",
        :options => {:dependent => :delete_all, :extend => []},
        :macro => :has_many
      }
    end

    it "has should belong to a workspace" do
      Group.reflect_on_association(:workspace).to_hash.should == {
        :class_name=>"Workspace",
        :options=>{},
        :macro=>:belongs_to,
      }
    end

  end

end

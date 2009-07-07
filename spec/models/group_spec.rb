# Parameters: {"group"=>{"associated_workspaces"=>["1", "2"],
#"title"=>"Group1", "description"=>"Group1"}, "group_id"=>"",
# "start_with"=>"j",
# "selected_Options"=>"Person_2,Person_1",
# "keyword"=>{"value"=>""}}


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Group do
  include ItemsSpecHelper
  fixtures :people
  def item
    Group.new
  end


  def group_attributes
    item_attributes
  end

  before(:each) do
    @group = item
  end

  it "should be valid" do
    @group.attributes = group_attributes
    @group.should be_valid
  end

  it "should have groupable objects" do
    # Dont know how to check.....just checked stupidly
    @group.attributes = item_attributes
    @group.groupable_objects = "Person_2,Person_1"
    @group.groupings.last.should == @group.groupings.last
  end

  it "should return members" do
    @group.attributes = item_attributes
    # Test Through fixtures
    @group.members.should == []
  end
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

    it "has many Users" do
      Group.reflect_on_association(:users).to_hash.should == {
        :class_name=>"User",
        :options=>{:source=>:user, :through=>:groupings, :extend=>[],:order=>"email ASC", :conditions=>"groupings.groupable_type = 'User'"},
        :macro=>:has_many,
      }
    end

    it "has many People" do
      Group.reflect_on_association(:people).to_hash.should == {
        :class_name=>"Person",
        :options=>{:source=>:person, :through=>:groupings, :extend=>[],:order=>"email ASC", :conditions=>"groupings.groupable_type = 'Person'"},
        :macro=>:has_many,
      }
    end

  end

end
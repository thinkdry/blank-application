# == Schema Information
# Schema version: 20181126085723
#
# Table name: workspaces
#
#  id                 :integer(4)      not null, primary key
#  creator_id         :integer(4)
#  description        :text
#  title              :string(255)
#  state              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  ws_items           :string(255)     default("")
#  ws_item_categories :string(255)     default("")
#  logo_file_name     :string(255)
#  logo_content_type  :string(255)
#  logo_file_size     :integer(4)
#  ws_available_types :string(255)     default("")
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Workspace do
  fixtures :users, :workspaces

  def workspace
    Workspace.new
  end


  def workspace_attributes
    {
      :title => 'Workspace Title',
      :description => 'Workspace Description',
      :state => 'private',
      :creator_id => users(:luc).id
    }
  end


  describe "attributes" do

    before(:each) do
      @workspace = workspace
    end

    it "should be valid" do
      @workspace.attributes = workspace_attributes
      @workspace.should be_valid
    end

    it "should require title" do
      @workspace.attributes = workspace_attributes.except(:title)
      @workspace.should have(1).error_on(:title)
    end

    it "should require description" do
      @workspace.attributes = workspace_attributes.except(:description)
      @workspace.should have(1).error_on(:description)
    end


  end

  describe "associations" do

    it "has many users workspaces" do
      Workspace.reflect_on_association(:users_workspaces).to_hash.should == {
        :macro => :has_many,
        :options => {:dependent=>:delete_all, :extend=>[]},
        :class_name => "UsersWorkspace"
      }
    end
    
    it "has many users through user workspaces" do
      Workspace.reflect_on_association(:users).to_hash.should =={
        :macro => :has_many,
        :options => {:through => :users_workspaces, :extend=>[]},
        :class_name => 'User'
      }
    end
    it "has many roles through user workspaces" do
      Workspace.reflect_on_association(:roles).to_hash.should == {
        :macro => :has_many,
        :options => {:through => :users_workspaces, :extend => []},
        :class_name => 'Role'
      }
    end
    it "has many items" do
      Workspace.reflect_on_association(:items).to_hash.should == {
        :macro => :has_many,
        :options => {:class_name=>"Item", :foreign_key=>"workspace_id", :extend=>[], :dependent=>:destroy},
        :class_name => 'Item'
      }
    end
    it "belongs to creator" do
      Workspace.reflect_on_association(:creator).to_hash.should == {
        :macro => :belongs_to,
        :options => {:class_name => 'User'},
        :class_name => 'Creator'
      }
    end
    it "belongs to ws config " do
      Workspace.reflect_on_association(:ws_config).to_hash.should == {
        :macro => :belongs_to,
        :options => {},
        :class_name => 'WsConfig'

      }
    end

  end


end


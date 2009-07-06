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
#Parameters: {"workspace"=>{"title"=>"Private for Boss",
# "existing_user_attributes"=>{"1"=>{"role_id"=>"4", "user_id"=>"1"}},
# "ws_item_categories"=>["cat1", "cat2", "cat3"],
# "description"=>"<p>Private Workspace for Boss</p>",
#  "ws_items"=>["article", "image", "cms_file", "video", "audio", "feed_source", "newsletter", "group"]},
#  "id"=>"1"}

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Workspace do
  fixtures :roles, :permissions, :users, :workspaces, :users_workspaces

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

  describe "should have named scopes" do

    before(:each) do
      @workspace = workspace
    end

    it "allowed_user_with_permission" do
      Workspace.allowed_user_with_permission(users(:luc).id, 'article_show').proxy_options.should == {:order=>"workspaces.title ASC"}
      Workspace.allowed_user_with_permission(users(:albert).id, 'article_show').proxy_options.should == {:joins=>"LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{users(:albert).id} LEFT JOIN permissions_roles ON permissions_roles.role_id = users_workspaces.role_id LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id", :conditions=>"permissions.name = 'article_show'",:order=>"workspaces.title ASC"}
    end

    it "allowed_user_with_ws_role" do
      Workspace.allowed_user_with_ws_role(users(:mj).id, 'ws_admin').proxy_options.should == {:joins=>"LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{users(:mj).id} LEFT JOIN roles ON roles.id = users_workspaces.role_id", :conditions=>"roles.name = 'ws_admin'"}
      Workspace.allowed_user_with_ws_role(users(:luc).id, 'superadmin').proxy_options.should == {:joins=>"LEFT JOIN users_workspaces ON users_workspaces.workspace_id = workspaces.id AND users_workspaces.user_id = #{users(:luc).id} LEFT JOIN roles ON roles.id = users_workspaces.role_id", :conditions=>"roles.name = 'superadmin'"}
    end

  end

  it "should return users of workspace with given role" do
    @workspace = workspaces(:private_for_luc)
    @workspace.users_by_role('ws_admin').last.should == User.find(1)
  end

  it "should save workspace items" do
    @workspace.attributes = workspace_attributes.merge("ws_items"=>["article", "image", "cms_file"])
    @workspace.ws_items.should == "article,image,cms_file"
  end
  
  #  it "should save existing user attributes" do
  #    @workspace.attributes = workspace_attributes.merge("existing_user_attributes"=>{"1"=>{"role_id"=>"4", "user_id"=>"1"}})
  #    @workspace.existing_user_attributes.should == users_workspaces(:one)
  #  end

  it "should save user workspace"

  describe "Permissions" do

    it "should allow user with role to administer workspace"
    
    it "should not allow user without role to administer workspace"

    it "should allow user with role to view workspace" 
    
    it "should not allow users without role to view workspace"

    it "should allow user with role to create workspace"

    it "should not allow users without role to create workspace"

    it "should allow user with role to edit workspace"

    it "should not allow users without role to edit workspace"

    it "should allow user with role to destroy workspace"

    it "should not allow users without role to destroy workspace"

  end


end


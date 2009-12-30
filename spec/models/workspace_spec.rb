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
require File.expand_path(File.dirname(__FILE__) + '/containers_spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/authorizable_spec_helper')

describe Workspace do
  fixtures :workspaces, :items_workspaces
  include AuthorizableSpecHelper
  include ContainersSpecHelper
  
  def container
    Workspace.new
  end
  
  def workspace_attributes
    container_attributes
  end
  
  before(:each) do
    @workspace = container
  end

  #item_specs(@article)
  
  it "should be valid" do
    @workspace.attributes = workspace_attributes
    @workspace.should be_valid
  end
  
end


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_container_spec_helper')

describe ItemsWorkspace do
  include ItemsContainerSpecHelper
  
  def items_container
    ItemsWorkspace.new
  end
  
  def items_workspace_attributes
    {
      :workspace_id => 10,
      :itemable_id => 1,
      :itemable_type => 'Image'
    }
  end
  
  before(:each) do
    @items_workspace = items_container
  end
  
  it "should be valid" do
    @items_workspace.attributes = items_workspace_attributes
    @items_workspace.should be_valid
  end
  
end

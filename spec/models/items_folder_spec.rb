require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_container_spec_helper')

describe ItemsFolder do
  include ItemsContainerSpecHelper
  
  def items_container
    ItemsFolder.new
  end
  
  def items_folder_attributes
    {
      :folder_id => 10,
      :itemable_id => 1,
      :itemable_type => 'Image'
    }
  end
  
  before(:each) do
    @items_folder = items_container
  end
  
  it "should be valid" do
    @items_folder.attributes = items_folder_attributes
    @items_folder.should be_valid
  end
  
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_container_spec_helper')

describe ItemsWebsite do
  include ItemsContainerSpecHelper
  
  def items_container
    ItemsWebsite.new
  end
  
  def items_website_attributes
    {
      :website_id => 10,
      :itemable_id => 1,
      :itemable_type => 'Image'
    }
  end
  
  before(:each) do
    @items_website = items_container
  end
  
  it "should be valid" do
    @items_website.attributes = items_website_attributes
    @items_website.should be_valid
  end
  
end

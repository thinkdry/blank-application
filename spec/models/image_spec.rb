require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Image do
  include ItemsSpecHelper
  
  def item
    Image.new
  end
  
  def image_attributes
    item_attributes
  end
    
  before(:each) do
    @image = item
  end
  
  it "should be valid" do
    @image.attributes = image_attributes
    @image.should be_valid
  end
  
  it "should require file_path"
end

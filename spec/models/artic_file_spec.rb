require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe ArticFile do
  include ItemsSpecHelper
  
  def item
    ArticFile.new
  end
  
  def artic_file_attributes
    item_attributes.merge(
      :file_path => upload_filepath_file('image.png')
    )
  end
  
  before(:each) do
    @artic_file = item
  end
  
  it "should be valid" do
    @artic_file.attributes = artic_file_attributes
    @artic_file.should be_valid    
  end
  
  it "should require file_path" do
    @artic_file.attributes = artic_file_attributes.except(:file_path)
    @artic_file.should have(1).error_on(:file_path)
  end
end
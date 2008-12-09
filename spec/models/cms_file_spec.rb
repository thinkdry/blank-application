require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe CmsFile do
  include ItemsSpecHelper
  
  def item
    CmsFile.new
  end
  
  def cms_file_attributes
    item_attributes.merge(
      :file_path => upload_filepath_file('image.png')
    )
  end
  
  before(:each) do
    @cms_file = item
  end
  
  it "should be valid" do
    @cms_file.attributes = cms_file_attributes
    @cms_file.should be_valid
  end
  
  it "should require file_path" do
    @cms_file.attributes = cms_file_attributes.except(:file_path)
    @cms_file.should have(1).error_on(:file_path)
  end
end
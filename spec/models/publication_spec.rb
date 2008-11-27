require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Publication do
  include ItemsSpecHelper
  
  def item
    Publication.new
  end
  
  def publication_attributes
    item_attributes.merge(:authors => 'The famous author')
  end
  
  before(:each) do
    @publication = Publication.new
  end
  
  it "should be valid" do
    @publication.attributes = publication_attributes
    @publication.should be_valid
  end
  
  it "should require author" do
    @publication.attributes = publication_attributes.except(:authors)
    @publication.should have(1).error_on(:authors)
  end
  
end
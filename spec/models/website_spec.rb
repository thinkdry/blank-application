require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/containers_spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/authorizable_spec_helper')

describe Website do
  fixtures :websites, :items_websites
  #include AuthorizableSpecHelper
  include ContainersSpecHelper

  def container
    Website.new
  end

  def website_attributes
    container_attributes
  end

  before(:each) do
    @website = container
  end

  #item_specs(@article)

  it "should be valid" do
    @website.attributes = website_attributes
    @website.should be_valid
  end

end

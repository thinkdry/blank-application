require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/containers_spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/authorizable_spec_helper')

describe Folder do
  fixtures :folders, :items_folders
  include AuthorizableSpecHelper
  include ContainersSpecHelper

  def container
    Folder.new
  end

  def folder_attributes
    container_attributes
  end

  before(:each) do
    @folder = container
  end

  #item_specs(@article)

  it "should be valid" do
    @folder.attributes = folder_attributes
    @folder.should be_valid
  end

end
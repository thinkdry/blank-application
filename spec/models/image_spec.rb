# == Schema Information
# Schema version: 20181126085723
#
# Table name: images
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  title       :string(255)
#  description :text
#  state       :string(255)
#  file_path   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  tags        :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Image do
  include ItemsSpecHelper
  
  def item
    Image.new
  end
  
  def image_attributes
    file_path = url_to_filepath_file('image.png')
    item_attributes.merge(:file_path => upload(file_path))
  end
  
  before(:each) do
    @image = item
  end
  
  it "should be valid" do
    @image.attributes = image_attributes
    @image.should be_valid
  end
  
  it "should require file_path" do
    @image.attributes = image_attributes.except(:file_path)
    @image.should have(1).error_on(:file_path)
  end
end

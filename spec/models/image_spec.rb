# == Schema Information
# Schema version: 20181126085723
#
# Table name: images
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  tags               :string(255)
#  viewed_number      :integer(4)
#  rates_average      :integer(4)
#  comments_number    :integer(4)
#  category           :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Image do
  include ItemsSpecHelper
  
  def item
    Image.new
  end
  
  def image_attributes
    image = url_to_filepath_file('image.png')
    item_attributes.merge(:image => upload(image))
  end
  
  before(:each) do
    @image = item
  end
  
  it "should be valid" do
    @image.attributes = image_attributes
    @image.should be_valid
  end
  
  it "should require image attachment" do
    @image.attributes = image_attributes.except(:image)
    @image.should have(1).error_on(:image)
  end

  it "should accept only [jpeg,jpg,png,gif,bmp] formats" do
    %w(image.jpeg image.jpg image.png image.gif image.bmp).each { |image|
      @image.attributes = item_attributes.merge(:image => File.new( RAILS_ROOT + '/spec/attachments/' + image))}
    @image.should be_valid
  end

  it "should have attachment size less than 25 MB" do
    @image.attributes = item_attributes.merge(:image => File.new( RAILS_ROOT + '/spec/attachments/image.png'))
    p @image.image
    @image.should be_valid
  end

end


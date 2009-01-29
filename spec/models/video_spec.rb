# == Schema Information
# Schema version: 20181126085723
#
# Table name: videos
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  title        :string(255)
#  description  :text
#  state        :string(255)
#  file_path    :string(255)
#  encoded_file :string(255)
#  thumbnail    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  tags         :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Video do
  include ItemsSpecHelper
  
  def item
    Video.new
  end
  
  before(:each) do
    @video = Video.new
  end
  
  it "should be valid" do
    @video.stub!(:file_path).and_return('/path/to/video.avi')
    @video.attributes = item_attributes
    @video.should be_valid
  end
  
  it "should require file_path" do
    @video.attributes = item_attributes
    @video.should have(1).error_on(:file_path)
  end
end

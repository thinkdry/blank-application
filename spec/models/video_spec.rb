# == Schema Information
# Schema version: 20181126085723
#
# Table name: videos
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)     default("initial")
#  video_file_name    :string(255)
#  video_content_type :string(255)
#  video_file_size    :integer(4)
#  video_updated_at   :datetime
#  encoded_file       :string(255)
#  thumbnail          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  viewed_number      :integer(4)      default(0)
#  rates_average      :integer(4)      default(0)
#  comments_number    :integer(4)      default(0)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Video do
  include ItemsSpecHelper
  
 def item
    Video.new
  end

  def video_attributes
    item_attributes.merge(:video => url_to_attachment_file('video.flv'))
  end

  before(:each) do
    @video = item
  end

  it "should be valid" do
    @video.attributes = video_attributes
    @video.should be_valid
  end

  it "should require video file" do
    @video.attributes = video_attributes.except(:video)
    @video.should have(1).error_on(:video)
  end

  it "should have attachment size less than 25 MB" do
    @video.attributes = video_attributes
    @video.video.size.should satisfy{|n| bytes_to_megabytes(n) < 25}
  end

  it "should have media type" do
    @video.attributes = video_attributes
    @video.media_type.should == @video.video
  end

  it "should have codec for Video Encoding" do
    @video.attributes = video_attributes
    @video.codec.should_not be_nil
  end

end

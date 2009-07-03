# == Schema Information
# Schema version: 20181126085723
#
# Table name: audios
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)     default("initial")
#  audio_file_name    :string(255)
#  audio_content_type :string(255)
#  audio_file_size    :integer(4)
#  audio_updated_at   :datetime
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

describe Audio do
  include ItemsSpecHelper
  
  def item
    Audio.new
  end

  def audio_attributes
    item_attributes.merge(:audio => url_to_attachment_file('audio.mp3'))
  end
  
  before(:each) do
    @audio = item
  end
  
  it "should be valid" do
    @audio.attributes = audio_attributes
    @audio.should be_valid
  end
  
  it "should require audio file" do
    @audio.attributes = audio_attributes.except(:audio)
    @audio.should have(1).error_on(:audio)
  end

  it "should have attachment size less than 25 MB" do
    @audio.attributes = audio_attributes
    @audio.audio.size.should satisfy{|n| bytes_to_megabytes(n) < 25}
  end

  it "should have media type" do
    @audio.attributes = audio_attributes
    @audio.media_type.should == @audio.audio
  end

  it "should have codec for Audio Encoding" do
    @audio.attributes = audio_attributes
    @audio.codec.should_not be_nil
  end



end

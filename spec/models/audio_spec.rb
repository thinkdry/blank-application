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
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Audio do
  include ItemsSpecHelper
  
  def item
    Audio.new
  end
  
  before(:each) do
    @audio = Audio.new
  end
  
  it "should be valid" do
    @audio.stub!(:file_path).and_return('/path/to/file.mp3')
    @audio.attributes = item_attributes
    @audio.should be_valid
  end
  
  it "should require file_path" do
    @audio.attributes = item_attributes
    @audio.should have(1).error_on(:file_path)
  end
end

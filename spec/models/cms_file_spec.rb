# == Schema Information
# Schema version: 20181126085723
#
# Table name: cms_files
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  title                :string(255)
#  description          :text
#  state                :string(255)
#  cmsfile_file_name    :string(255)
#  cmsfile_content_type :string(255)
#  cmsfile_file_size    :integer(4)
#  cmsfile_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  tags                 :string(255)
#  viewed_number        :integer(4)
#  rates_average        :integer(4)
#  comments_number      :integer(4)
#  category             :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe CmsFile do
  include ItemsSpecHelper
  
  def item
    CmsFile.new
  end

  def cms_file_attributes
    item_attributes.merge(:cmsfile => url_to_attachment_file('cms_file.pdf'))
  end

  before(:each) do
    @cms_file = item
  end

  it "should be valid" do
    @cms_file.attributes = cms_file_attributes
    @cms_file.should be_valid
  end

  it "should require cms_file attachment" do
    @cms_file.attributes = cms_file_attributes.except(:cmsfile)
    @cms_file.should have(1).error_on(:cmsfile)
  end

  it "should have attachment size less than 25 MB" do
    @cms_file.attributes = cms_file_attributes
    @cms_file.cmsfile.size.should satisfy{|n| bytes_to_megabytes(n) < 25}
  end
end

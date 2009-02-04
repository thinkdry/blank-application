# == Schema Information
# Schema version: 20181126085723
#
# Table name: publications
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  feed_source_id :integer(4)
#  title          :string(255)
#  description    :text
#  state          :string(255)
#  link           :string(255)
#  enclosures     :string(255)
#  authors        :string(255)
#  date_published :datetime
#  last_updated   :datetime
#  copyright      :string(255)
#  categories     :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  tags           :string(255)
#

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

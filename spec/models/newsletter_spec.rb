require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Newsletter do
  include ItemsSpecHelper
  
  def item
    Newsletter.new
  end

  def newsletter_attributes
    item_attributes.merge(:body => 'Newsletter Body',:from_email => 'contact@thinkdry.com')
  end

  before(:each) do
    @newsletter = item
  end

  it "should be valid" do
    @newsletter.attributes = newsletter_attributes
    @newsletter.should be_valid
  end

  it "should require body on updation" do
    @newsletter.attributes = newsletter_attributes.except(:body)
    @newsletter.should have(1).error_on(:body) if !@newsletter.new_record?
  end
  
  it "should validate presence of from email" do
    @newsletter.attributes = newsletter_attributes.except(:from_email)
    @newsletter.should have(3).errors_on(:from_email)
  end
  
  it "should accept valid format of from email" do
    @newsletter.attributes = newsletter_attributes
    @newsletter.from_email = 'think#gmail.com'
    @newsletter.should have(1).errors_on(:from_email)
  end

  it "has and belongs to groups" do
    Newsletter.reflect_on_association(:groups).to_hash == {
      :macro => :has_and_belongs_to_many,
      :options => {},
      :class_name => 'Group'
    }
  end

  it "has many groups newsletters" do
    Newsletter.reflect_on_association(:groups_newsletters).to_hash == {
      :macro => :has_many,
      :options => {},
      :class_name => 'GroupNewsletter'
    }
  end

end
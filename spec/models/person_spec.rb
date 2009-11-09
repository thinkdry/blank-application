require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/email_spec_helper')

describe Person do
  include EmailSpecHelper
#  extend EmailSpecHelper::ClassMethods
  fixtures :people

  def object
    Person.new
  end

  def person_attributes
    {
      :email => 'contact@thinkdry.com'
    }
  end

  before(:each) do
    @person = object
  end

  it "should be valid" do
    @person.attributes = person_attributes
  end

  it "should validate uniqueness of email for given user" do
    @person = people(:one)
    @person.validate_uniqueness_of_email.should == false
  end

  it "should return the full name of the person" do
    @person = people(:two)
    @person.full_name.strip.should == ""
  end

  it "should convert user to person" do
    
  end

  it "should convert person to group member" do
    
  end


end
# == Schema Information
# Schema version: 20181126085723
#
# Table name: articles
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#  tags            :string(255)
#  viewed_number   :integer(4)
#  rates_average   :integer(4)
#  comments_number :integer(4)
#  category        :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Article do
  include ItemsSpecHelper
  
  def item
    Article.new
  end
  
  def article_attributes
    item_attributes
  end
  
  before(:each) do
    @article = item
  end

  #item_specs(@article)
  
  it "should be valid" do
    @article.attributes = article_attributes
    @article.should be_valid
  end
  
  it "should require body on update" do
    @article.attributes = article_attributes.except(:body)
    @article.should have(1).error_on(:body) if !@article.new_record?
  end

  
  describe "attachements" do
    
    it "should accept one new file" do
      @article.attributes = article_attributes
      @article.new_file_attributes = [{:articlefile => url_to_attachment_file('image.png')}]
      @article.article_files.size.should == 1
      @article.article_files.first.articlefile.should_not be_nil
    end
    
    it "should accepts file names with spaces" do
      @article.attributes = article_attributes
      @article.new_file_attributes =  [{:articlefile => url_to_attachment_file('filename with spaces.txt')}]
      @article.article_files.size.should == 1
      @article.article_files.first.articlefile.should_not be_nil
    end
    
  end
end

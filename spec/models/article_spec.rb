require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Article do
  include ItemsSpecHelper
  
  def item
    Article.new
  end
  
  def article_attributes
    item_attributes.merge(
      :body => 'My body content'
    )
  end
  
  before(:each) do
    @article = item
  end
  
  it "should be valid" do
    @article.attributes = article_attributes
    @article.should be_valid
  end
  
  it "should require body" do
    @article.attributes = article_attributes.except(:body)
    @article.should have(1).error_on(:body)
  end
  
  describe "attachements" do
    
    it "should accept one new file" do
      @article.attributes = article_attributes
      file_path = ActionController::TestUploadedFile.new \
        url_to_filepath_file('image.png'),
        'image/png'
      @article.new_file_attributes = [file_path]
      @article.article_files.size.should == 1
      @article.article_files.first.file_path.should_not be_nil
    end
    
    it "should accepts file names with spaces" do
      @article.attributes = article_attributes
       file_path = ActionController::TestUploadedFile.new \
         url_to_filepath_file('filename with spaces.txt'),
         'image/png'
       @article.new_file_attributes = [file_path]
       @article.article_files.size.should == 1
       @article.article_files.first.file_path.should_not be_nil
    end
    
  end
end
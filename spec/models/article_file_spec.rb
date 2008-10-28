require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleFile do
  
  def article_file_attributes
    { :article_id => 42,
      :file_path => upload(File.expand_path(File.dirname(__FILE__) + '/../file_path/image.png')) }
  end
  
  before(:each) do
    @article_file = ArticleFile.new
  end
  
  it "should be valid" do
    @article_file.attributes = article_file_attributes
    @article_file.should be_valid
  end
  
  it "should require file_path" do
    @article_file.attributes = article_file_attributes.except(:file_path)
    @article_file.should have(1).error_on(:file_path)
  end
  
  it "should not validates empty files" do
    @article_file.attributes = article_file_attributes.merge(
      :file_path => upload(File.expand_path(File.dirname(__FILE__) + '/../file_path/empty_file.txt')))
    @article_file.should have(1).error_on(:file_path)
  end
  
end
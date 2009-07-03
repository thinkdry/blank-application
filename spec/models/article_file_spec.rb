# == Schema Information
# Schema version: 20181126085723
#
# Table name: article_files
#
#  id                       :integer(4)      not null, primary key
#  article_id               :integer(4)
#  articlefile_file_name    :string(255)
#  articlefile_content_type :string(255)
#  articlefile_file_size    :integer(4)
#  articlefile_updated_at   :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleFile do
  
  def article_file_attributes
    { :article_id => 42,
      :articlefile => upload_filepath_file('image.png') }
  end
  
  before(:each) do
    @article_file = ArticleFile.new
  end
  
  it "should be valid" do
    @article_file.attributes = article_file_attributes
    @article_file.should be_valid
  end
  
  it "should require articlefile" do
    @article_file.attributes = article_file_attributes.except(:articlefile)
    @article_file.should have(1).error_on(:articlefile)
  end
  
#  it "should not validates empty files" do
#    @article_file.attributes = article_file_attributes.merge(
#      :articlefile => upload_filepath_file('empty_file.txt'))
#    @article_file.should have(1).error_on(:articlefile)
#  end
  
end

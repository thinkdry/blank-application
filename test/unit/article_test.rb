require 'test_helper'

class ArticleTest < Test::Unit::TestCase
  # Replace this with your real tests.
	
	def test_should_create_article
    assert_difference 'Article.count' do
      article = create_article
      assert !article.new_record?, "#{article.errors.full_messages.to_sentence}"
    end
  end
	
  def test_title_should_not_validate
		# require
    assert_invalid_format :title, [""]
  end
	
	def test_description_should_not_validate
		# require
    assert_invalid_format :description, [""]
  end
	
	def test_file_path_should_not_validate
		# require
    assert_invalid_format :introduction, [""]
  end	
	
	def test_file_path_should_not_validate
		# require
    assert_invalid_format :body, [""]
  end	
	
	def test_file_path_should_not_validate
		# require
    assert_invalid_format :conclusion, [""]
  end
	
	def test_remove_element_associated_when_object_destroyed
		assert id = articles(:one).id, "Article nil"
		assert ArticleFile.count(:all, :conditions => {:article_id => id})!=0, "No elements in the A-AF join table"
		assert articles(:one).destroy, "Cannot destroy the article"
		assert ArticleFile.count(:all, :conditions => {:article_id => id})==0, "Artic files associated not removed"
	end
	
	protected
		def create_article(options = {})
    record = Article.new({
			:user => users(:quentin),
      :title => 'myArticle',
			:description => "tralali tralala",
			:introduction => "intro",
			:body => "boudy",
			:conclusion => "the end"
			}.merge(options))
    record.save
    record
  end
	
end
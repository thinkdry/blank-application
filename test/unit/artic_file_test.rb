require 'test_helper'

class ArticFileTest < Test::Unit::TestCase
  # Replace this with your real tests.
	
	def test_should_create_articfile
    assert_difference 'ArticFile.count' do
      artic_file = create_articfile
      assert !artic_file.new_record?, "#{artic_file.errors.full_messages.to_sentence}"
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
    assert_invalid_format :file_path, [""]
  end	
	
	protected
		def create_articfile(options = {})
    record = ArticFile.new({
      :title => 'myPhoto',
			:description => "tralali tralala"
			#:file_path => 
			}.merge(options))
    record.save
    record
  end
	
end
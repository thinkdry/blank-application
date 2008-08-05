require 'test_helper'

class AudioTest < Test::Unit::TestCase
  # Replace this with your real tests.
	
	def test_should_create_audio
    assert_difference 'Audio.count' do
      audio = create_audio
      assert !audio.new_record?, "#{audio.errors.full_messages.to_sentence}"
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
		def create_audio(options = {})
    record = Audio.new({
			:user => users(:quentin),
      :title => 'myPhoto',
			:description => "tralali tralala",
			:file_path => upload("#{RAILS_ROOT}/test/file_column_files/Record Dolphin.png")
			}.merge(options))
    record.save
    record
  end
	
end
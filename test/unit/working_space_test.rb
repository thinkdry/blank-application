require 'test_helper'

class WorkingSpaceTest < Test::Unit::TestCase
	
	def test_should_create_working_space
    assert_difference 'WorkingSpace.count' do
      working_space = create_working_space
      assert !working_space.new_record?, "#{working_space.errors.full_messages.to_sentence}"
    end
  end
	
  def test_name_should_not_validate
		# require
    assert_invalid_format :name, [""]
  end
	
	protected
  def create_working_space(options = {})
    record = WorkingSpace.new({
      :name => 'demi-fond',
			}.merge(options))
    record.save
    record
  end


end

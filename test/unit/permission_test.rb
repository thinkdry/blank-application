require 'test_helper'

class PermissionTest < Test::Unit::TestCase
  # Replace this with your real tests.
	
	def test_should_create_permission
    assert_difference 'Permission.count' do
      permission = create_permission
      assert !permission.new_record?, "#{permission.errors.full_messages.to_sentence}"
    end
  end
	
  def test_name_should_not_validate
		# require
    assert_invalid_format :name, [""]
  end
	
	protected
  def create_permission(options = {})
    record = Permission.new({
      :name => 'courir',
			}.merge(options))
    record.save
    record
  end

end

require 'test_helper'

class RoleTest < Test::Unit::TestCase
  	
	def test_should_create_role
    assert_difference 'Role.count' do
      role = create_role
      assert !role.new_record?, "#{role.errors.full_messages.to_sentence}"
    end
  end
	
  def test_name_should_not_validate
		# require
    assert_invalid_format :name, [""]
  end
	
	protected
  def create_role(options = {})
    record = Role.new({
      :name => 'courreur',
			}.merge(options))
    record.save
    record
  end


end

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
	
	def test_remove_element_associated_when_object_destroyed
		assert id = permissions(:one).id, "Permission nil"
		assert PermissionsRole.count(:all, :conditions => {:permission_id => id})!=0, "No elements in the P-R join table"
		assert permissions(:one).destroy, "Cannot destroy the permission"
		assert PermissionsRole.count(:all, :conditions => {:permission_id => id})==0, "Roles associated not removed"
		
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

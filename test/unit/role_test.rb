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
	
	def test_remove_element_associated_when_object_destroyed
		assert id = roles(:one).id, "Role nil"
		assert PermissionsRole.count(:all, :conditions => {:role_id => id})!=0, "No elements in the P-R join table"
		assert UsersWorkspace.count(:all, :conditions => {:role_id => id})!=0, "No elements in the U-W join table"
		assert roles(:one).destroy, "Cannot destroy the role"
		assert PermissionsRole.count(:all, :conditions => {:role_id => id})==0, "Permissions associated not removed"
		assert UsersWorkspace.count(:all, :conditions => {:role_id => id})==0, "UsersWorkspaces associated not removed"
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

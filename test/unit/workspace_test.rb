require 'test_helper'

class WorkspaceTest < Test::Unit::TestCase
	
	def test_should_create_workspace
    assert_difference 'Workspace.count' do
      workspace = create_workspace
      assert !workspace.new_record?, "#{workspace.errors.full_messages.to_sentence}"
    end
  end
	
  def test_name_should_not_validate
		# require
    assert_invalid_format :name, [""]
  end
	
	def test_no_same_user_in_workspace
		workspace = create_workspace
		assert workspace.users_workspaces.build(:user_id => users(:quentin), :role_id => roles(:two))
		assert_difference 'workspace.users_workspaces.count' do
			assert !workspace.users_workspaces.build(:user_id => users(:quentin), :role_id => roles(:one)), "Doublon user"
		end
  end
	
	protected
  def create_workspace(options = {})
    record = Workspace.new({
      :name => 'demi-fond',
			}.merge(options))
    record.save
    record
  end


end

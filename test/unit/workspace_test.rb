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
    assert_invalid_format :name, ""
  end
	
	def test_should_not_validate_with_new_user_allready_associated
		workspace = create_workspace
		# Create a record in users_workspaces
		assert workspace.users_workspaces.create(:user_id => users(:quentin), :role_id => roles(:two))
		assert_no_difference 'workspace.users_workspaces.count' do
			assert workspace.users_workspaces.build(:user_id => users(:quentin), :role_id => roles(:one))
			assert !workspace.save
		end
  end
  
  def test_should_not_validate_with_news_users_identicals
		workspace = create_workspace
		# Build (!) a record in users_workspaces => usual `validate_associated` failed in this case
		assert workspace.users_workspaces.build(:user_id => users(:quentin), :role_id => roles(:two))
		assert_no_difference 'workspace.users_workspaces.count' do
			assert workspace.users_workspaces.build(:user_id => users(:quentin), :role_id => roles(:one))
			assert !workspace.save
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

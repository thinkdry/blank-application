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
	
	protected
  def create_workspace(options = {})
    record = Workspace.new({
      :name => 'demi-fond',
			}.merge(options))
    record.save
    record
  end


end

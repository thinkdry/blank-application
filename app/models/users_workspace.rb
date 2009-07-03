# == Schema Information
# Schema version: 20181126085723
#
# Table name: users_workspaces
#
#  id           :integer(4)      not null, primary key
#  workspace_id :integer(4)
#  role_id      :integer(4)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class UsersWorkspace < ActiveRecord::Base
	
	belongs_to :user

	belongs_to :workspace

	belongs_to :role

	#Validations
	validates_presence_of :user_id, :role_id, :workspace_id
  
	validates_uniqueness_of :user_id, :scope => :workspace_id


	def user_login
	  user.nil? ? String.new : user.login
  end

  # Find by login and Assocaite Users to UsersWorksapce
  def user_login=(login)
    self.user = User.find_by_login(login)
  end
end

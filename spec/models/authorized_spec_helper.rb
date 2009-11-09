module AuthorizedSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users, :workspaces, :roles

      describe "Authorized" do

        before do
          @object = object
        end

        it "should include workspace role'(s)" do
          @object.class.to_s.classify.constantize.reflect_on_association(:workspace_roles).to_hash.should == {
            :macro => :has_many,
            :options => { :through => :users_workspaces, :source => :role, :extend => [] },
            :class_name => 'WorkspaceRole'
          }
        end

        it "should return system role of the user" do
          users(:luc).system_role.should == roles(:superadmin)
        end

        it "should check if the user has the given system role" do
          users(:albert).has_system_role('admin').should eql true
        end

        it "should check if the user has the workspace rol to access" do
          users(:albert).has_workspace_role(2,'admin').should eql true
        end

        it "should return the permissions for the users system role" do
          users(:albert).system_permissions.should == Permission.all
        end

        it "should return the permissions for workspace" do
          users(:albert).workspace_permissions(2).should == UsersWorkspace.find(:first, :conditions => {:user_id => 2, :workspace_id => 2}).role.permissions
        end

        it "should return the permission for user given the controller & action" do
          users(:luc).has_system_permission('articles','new').should eql true
        end

        it "should return the permission for the workspace given the workspace, controller & action" do
          users(:albert).has_workspace_permission(2,'article','new').should eql true
        end
      end
    end
  end
end


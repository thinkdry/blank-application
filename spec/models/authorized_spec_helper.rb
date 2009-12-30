module AuthorizedSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users, :workspaces, :roles, :users_containers

      describe "Authorized" do

        before do
          @object = object
        end

        it "should include container role'(s)" do
          @object.class.to_s.classify.constantize.reflect_on_association(:container_roles).to_hash.should == {
            :macro => :has_many,
            :options => { :through => :users_containers, :source => :role, :extend => [] },
            :class_name => 'ContainerRole'
          }
        end

        it "should return system role of the user" do
          users(:luc).system_role.should == roles(:superadmin)
        end

        it "should check if the user has the given system role" do
          users(:albert).has_system_role('admin').should eql true
        end

        it "should check if the user has the container role to access" do
          users(:albert).has_container_role(2, 'workspace', 'co_admin').should eql true
        end

        it "should return the permissions for the users system role" do
          users(:albert).system_permissions.should == Permission.all
        end

        it "should return the permissions for workspace" do
          users(:albert).container_permissions(2,'workspace').should == UsersContainer.find(:first, :conditions => {:user_id => 2, :containerable_id => 2, :containerable_type => 'Workspace'}).role.permissions
        end

        it "should return the permission for user given the controller & action" do
          users(:luc).has_system_permission('articles','new').should eql true
        end

        it "should return the permission for the workspace given the workspace, controller & action" do
          users(:albert).has_container_permission(2,'article','new','workspace').should eql true
        end
      end
    end
  end
end


module AuthorizableSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users, :roles, :permissions, :users_containers

      before do
        @object = object
        @object_name = @object.class.to_s.underscore
        @object_instance = @object_name.classify.constantize
      end


      it "should include the desired module " do
        @object.class.included_modules.should include(Authorizable::ModelMethods::InstanceMethods)
        if ITEMS.include?(@object_name)
          @object.class.included_modules.should include(Authorizable::ModelMethods::ItemInstanceMethods)
        end
        if CONTAINERS.include?(@object_name)
          @object.class.included_modules.should include(Authorizable::ModelMethods::ContainerInstanceMethods)
        end
        if @object_name == 'user'
          @object.class.included_modules.should include(Authorizable::ModelMethods::UserInstanceMethods)
        end
      end

      actions.each do |action|
        it "should return access for #{action} & for user 'superadmin'" do
          @object.has_permission_for?(action, users(:luc), 'workspace').should == true
        end
      end

    end
  end
end


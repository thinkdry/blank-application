module AuthorizableSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users, :workspaces, :roles, :permissions

      before do
        @object = object
      end


      it "should include the desired module " do
        @object.class.included_modules.should include(Authorizable::ModelMethods::InstanceMethods)
        if ITEMS.include?(@object.class.to_s.underscore)
          @object.class.included_modules.should include(Authorizable::ModelMethods::IMItem)
        end
        if @object.class.to_s.underscore == 'workspace'
          @object.class.included_modules.should include(Authorizable::ModelMethods::IMWorkspace)
        end
        if object.class.to_s.underscore == 'user'
          @object.class.included_modules.should include(Authorizable::ModelMethods::IMUser)
        end
      end

      actions.each do |action|
        it "should return access for #{action} & for user 'superadmin'" do
          @object.has_permission_for?(action, users(:luc)).should == true
        end
      end

      #actions.each do |action|
      #  it "should return access for #{action} & for user 'admin'" do
      #    @object.has_permission_for?(action, users(:albert)).should == true
     #   end
     # end

     # actions.each do |action|
     #   it "should return access for #{action} & for user 'user'" do
     #     @object.has_permission_for?(action, users(:leo)).should == false
     #   end
    #  end
    end
  end
end


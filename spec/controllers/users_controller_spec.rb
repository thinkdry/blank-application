require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::UsersController do

#  describe "responding to GET show" do
#    # @is_admin = @current_object.system_role == "Admin"
#    # @moderated_ws =
#    #   Workspace.with_moderator_role_for(@current_object) |
#    #   Workspace.administrated_by(@current_object)
#    # @writter_role_on_ws = Workspace.with_writter_role_for(@current_object)
#    # @reader_role_on_ws = Workspace.with_reader_role_for(@current_object)
#    fixtures :users
#
#    def mock_user(stubs={})
#      @mock_user ||= mock_model(User, stubs)
#    end
#
#    before(:each) do
#      controller.send(:current_user=, users(:luc))
#    end
#
#    it "should find the user find the id parameter" do
#      User.should_receive(:find).with("42").once
#      get :show, :id => "42"
#    end
#
#    it "should assigns current_object" do
#      User.should_receive(:find).with("21").once.and_return(mock_user)
#      get :show, :id => "21"
#      assigns[:current_object].should == mock_user
#    end
#
#    it "should assigns is_admin to true when user instance responds true to 'is_admin?'" do
#      User.should_receive(:find).with("42").once.and_return(mock_user(:is_admin? => true))
#      get :show, :id => "42"
#      assigns[:is_admin].should == true
#    end
#
#    it "should assigns is_admin to false when user instance responds true to 'is_admin?'" do
#      User.should_receive(:find).with("42").once.and_return(mock_user(:is_admin? => false))
#      get :show, :id => "42"
#      assigns[:is_admin].should == false
#    end
#
#    it "should assigns moderated_ws" do
#      get :show, :id => users(:albert).id.to_s
#      assigns[:moderated_ws].should_not be_nil
#    end
#
#    it "should assigns writter_role_on_ws" do
#      get :show, :id => users(:albert).id.to_s
#      assigns[:writter_role_on_ws].should_not be_nil
#    end
#
#    it "should assigns reader_role_on_ws" do
#      get :show, :id => users(:albert).id.to_s
#      assigns[:reader_role_on_ws].should_not be_nil
#    end
#
#  end

end

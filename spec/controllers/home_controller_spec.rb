require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  controller_name :home

  describe "responding to GET index" do

    #before(:each) do
    #  @current_user = mock_model(User)
    #  controller.stub!(:current_user).and_return(@current_user)
    #  controller.stub!(:set_locale).and_return(true)
    #  controller.stub!(:get_configuration).and_return(true)
    #  controller.stub!(:get_da_layout).and_return('application')
    #end

    #it "should assigns latest users & latest workspaces" do
    #  @latest_ws = mock_model(Workspace)
    #  Workspace.stub!(:allowed_user_with_permission).
    #            with(@current_user.id, 'workspace_show').
    #            stub!(:all).
    #            with(:order => "created_at DESC").
    #            and_return(@latest_ws)
    #  @latest_users = mock_model(User)
    #  User.stub!(:latest).and_return(@latest_users)
    #  get :index
    #  assigns[:latest_users].should == @latest_users
    #  assigns[:latest_ws].should == @latest_ws
    #end

 end

  describe "responding to autocomplete_on" do

    #before(:each) do
    #  controller.stub!(:current_user).and_return(true)
    #  controller.stub!(:set_locale).and_return(true)
    #  controller.stub!(:get_configuration).and_return(true)
    #end

   #it "should render the text for the users list" do
   #  post :autocomplete_on, :model_name => 'keyword', :name => 'rai'
  # response.should have_tag('ul')
   #end

 end
end


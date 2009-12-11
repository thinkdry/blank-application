require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::ArticlesController do
  controller_name 'admin/articles'

  before(:each) do
    @current_user = mock_model(User, :login => 'boss', :u_per_page => 10, :u_layout => 'app_fat_menu')
    controller.stub!(:current_user).and_return(@current_user)
    controller.stub!(:set_locale).and_return(true)
    controller.stub!(:get_configuration).and_return(true)
    controller.stub!(:get_da_layout).and_return('application')
    controller.stub!(:permission_checking).and_return(true)
  end

  describe 'GET new' do

    before(:each) do
      @current_object = mock_model(Article)
    end

    it "assigns current_object as new record" do
      Article.stub!(:new).and_return(@current_object)
      get :new
      assigns[:current_object].should eql(@current_object)
    end

  end

  describe "POST to create" do

    describe "for valid Article" do

      before(:each) do
        @current_object = mock_model(Article, :save => true)
        Article.stub!(:new).and_return(@current_object)
        @params = {"associated_workspaces"=>["1"], "title"=>"hello", "description"=>"world", "body"=>"good job on rspec", "keywords_field"=>[]}
      end

      def do_post
        @current_object.should_receive(:user_id=).with(@current_user.id)
        post :create, :article => @params
      end

      it "should create new record" do
        Article.should_receive(:new).with(@params).and_return(@current_object)
        do_post
      end

      it "should save new record" do
        @current_object.should_receive(:save).and_return(true)
        do_post
      end

      it "should redirect to edit page after successfull creation of record" do
        do_post
        assigns(:current_object).should eql(@current_object)
        response.should redirect_to edit_admin_article_url(@current_object)
      end

    end

    describe "for invalid Article" do

      before(:each) do
        @current_object = mock_model(Article, :save => false)
        Article.stub!(:new).and_return(@current_object)
        @params = {"associated_workspaces"=>["1"], "description"=>"world", "keywords_field"=>[]}
      end

      def do_post
        @current_object.should_receive(:user_id=).with(@current_user.id)
        post :create, :article => @params
      end

      it "should fail creation of new record" do
        Article.should_receive(:new).with(@params).and_return(@current_object)
        @current_object.should_receive(:save).and_return(false)
        do_post
      end

      it "should render new if record creation fails" do
        do_post
        assigns(:current_object).should eql(@current_object)
        response.should render_template('generic_for_item/new')
      end
    end
  end

  describe 'GET edit' do

    before(:each) do
      @current_object = mock_model(Article)
    end

    def do_get
      get :edit, :id => 1
    end

    it "assigns current_object as new record" do
      Article.should_receive(:find).with('1').and_return(@current_object)
      do_get
      assigns[:current_object].should eql(@current_object)
    end

  end


  describe "PUT to update" do

    describe "for valid Article" do

      before(:each) do
        @current_object = mock_model(Article, :update_attributes => true)
        Article.stub!(:find).and_return(@current_object)
        @params = {"associated_workspaces"=>["1"], "title"=>"hello", "description"=>"world", "body"=>"rspec rocks!", "keywords_field"=>[]}
      end

      def do_put
        put :update, :id => @current_object.id, :article => @params
      end

      it "should find record with id & update_attributes" do
        Article.should_receive(:find).with("#{@current_object.id}").and_return(@current_object)
        @current_object.should_receive(:update_attributes).with(@params).and_return(@current_object)
        do_put
      end

      it "should redirect to show after successfull updation of record" do
        do_put
        assigns(:current_object).should eql(@current_object)
        response.should redirect_to admin_article_url(@current_object)
      end

      it "should make session values of fck editor to nil" do
        do_put
        session[:fck_item_id].should be_nil
        session[:fck_item_type].should be_nil
      end

    end

    describe "for invalid Article" do

      before(:each) do
        @current_object = mock_model(Article, :update_attributes => false)
        Article.stub!(:find).and_return(@current_object)
        @params = {"associated_workspaces"=>["1"], "title"=>"hello", "description"=>"world", "keywords_field"=>[]}
      end

      def do_put
        put :update, :id => @current_object.id, :article => @params
      end

      it "should find record with id & update_attributes" do
        Article.should_receive(:find).with("#{@current_object.id}").and_return(@current_object)
        @current_object.should_receive(:update_attributes).with(@params).and_return(false)
        do_put
      end

      it "should redirect to show after successfull updation of record" do
        do_put
        assigns(:current_object).should eql(@current_object)
        response.should render_template('generic_for_item/edit')
      end
    end

  end

  describe "DELETE destroy" do

    before(:each) do
      @current_object = mock_model(Article, :destroy => true)
      Article.stub!(:find).and_return(@current_object)
      @params = {}
    end

    def do_delete
      delete :destroy, :id => @current_object.id
    end

    it "destroys the requested article" do
      Article.should_receive(:find).with("#{@current_object.id}").and_return(@current_object)
      @current_object.should_receive(:destroy).and_return(true)
      do_delete
    end

    it "redirects to the employees list" do
      do_delete
      response.should redirect_to(admin_content_path(:item_type => 'articles'))
    end
  end

  describe "GET show" do

    before(:each) do
      @current_object = mock_model(Article, :viewed_number => 10, :save => true)
      Article.stub!(:find).and_return(@current_object)
      @params = {}
    end

    def do_get
      @current_object.should_receive(:viewed_number=).with(11)
      get :show, :id => @current_object.id
    end

    it "should display all the information of the article" do
      Article.should_receive(:find).with("#{@current_object.id}").and_return(@current_object)
      do_get
    end

    it "should increase the count of viewed number by 1" do
      @current_object.should_receive(:save).and_return(:true)
      do_get
      assigns(:current_object).should eql(@current_object)
    end
  end

  describe "GET index" do

    before do
      @paginated_objects = mock_model(Article)
      Article.stub!(:find).with(:all).and_return([@paginated_objects])
      @params = {}
    end

    def do_get
      Article.should_receive(:get_da_objects_list).and_return(@paginated_objects)
      get :index
    end

    it "assigns all articles" do
      do_get
      assigns(:paginated_objects).should eql(@paginated_objects)
    end

  end


end


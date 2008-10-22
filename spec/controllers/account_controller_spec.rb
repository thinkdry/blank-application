require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountController do
  
  describe "responding to GET index" do
    
    # @latest_items = GenericItem.latest
    # @latest_users = User.latest
    # @latest_pubmed = PubmedItem.latest
    # @latest_ws = Workspace.latest
    
    fixtures :users
    
    before(:each) do
      controller.send(:current_user=, users(:luc))
      get :index      
    end
    
    it "should assigns latest_items" do
      assigns[:latest_items].should_not be_nil
    end
    
    it "should assigns latest_users" do
      assigns[:latest_users].should_not be_nil
    end
    
    it "should assigns latest_pubmed" do
      assigns[:latest_pubmed].should_not be_nil
    end
    
    it "should assigns latest_ws" do
      assigns[:latest_ws].should_not be_nil
    end
    
    describe "Latest items" do
      
      fixtures :images
      
      it "should not contain items you cannot consult" do
        assigns[:latest_items].should_not include(images(:created_by_albert_in_the_future))
      end
      
    end
    
    describe "Latest pubmed imports" do
      fixtures :pubmed_sources, :pubmed_items
      
      it "should not display items from sources user is not the owner" do
        accessible_items = pubmed_sources(:created_by_luc).pubmed_items
        assigns[:latest_pubmed].each do |pubmed_item|
          accessible_items.should include(pubmed_item)
        end
      end
      
    end
    
  end
  
end
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  describe "responding to GET index" do
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
    
#    it "should assigns latest_pubmed" do
#      assigns[:latest_pubmed].should_not be_nil
#    end
    
    it "should assigns latest_ws" do
      assigns[:latest_ws].should_not be_nil
    end
    
    describe "Latest items" do
      
      fixtures :images
      
      it "should not contain items you cannot consult" do
        assigns[:latest_items].should_not include(images(:created_by_albert_in_the_future))
      end
      
    end
    
#    describe "Latest pubmed imports" do
#      fixtures :feed_sources, :feed_items
#
#      it "should not display items from sources user is not the owner" do
#        accessible_items = feed_sources(:created_by_luc).feed_items
#        assigns[:latest_pubmed].each do |feed_item|
#          accessible_items.should include(feed_item)
#        end
#      end
#
#    end
    
  end
  
end
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
  
  describe "route generation" do
    
    it "should map index action to root url" do
      route_for(:controller => "home", :action => "index").should == "/"
    end
    
  end
  
end
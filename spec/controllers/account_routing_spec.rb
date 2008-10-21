require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountController do
  
  describe "route generation" do
    
    it "should map index action to root url" do
      route_for(:controller => "account", :action => "index").should == "/"
    end
    
  end
  
end
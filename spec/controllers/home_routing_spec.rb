require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::HomeController do

 describe "route generation" do

    it "should map index action to root url" do
      route_for(:controller => "admin/home", :action => "index").should == "/admin"
    end
  end

end


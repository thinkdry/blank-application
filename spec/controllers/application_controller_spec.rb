require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::ApplicationController do

  describe "before filters" do

    it "should have a filter for checking if user is logged in" do
      Admin::ApplicationController.before_filters.should include(:is_logged?)
    end

    it "should have a filter for settings the locales" do
      Admin::ApplicationController.before_filters.should include(:set_locale)
    end

    it "should have a filter for setting default configuration" do
      Admin::ApplicationController.before_filters.should include(:get_configuration)
    end

  end
  
#TODO Learn to write application controller specs, how to get @configuration?  
#  describe 'method' do
#  
#    before(:each) do
#      @configuration ||= get_sa_config
#      controller.stub!(:get_configuration).and_return(@configuration)
#    end
#  
#    it 'should return items types depending on container' do
#      get_configuration
#      p controller.get_allowed_item_types(mock_model(Workspace, :available_items => "article,image"))
#    end
#    
#  end

end


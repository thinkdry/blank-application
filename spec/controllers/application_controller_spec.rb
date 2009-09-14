require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do


  describe "before filters" do

    it "should have a filter for checking if user is logged in" do
      ApplicationController.before_filters.should include(:is_logged?)
    end

    it "should have a filter for settings the locales" do
      ApplicationController.before_filters.should include(:set_locale)
    end

    it "should have a filter for setting default configuration" do
      ApplicationController.before_filters.should include(:get_configuration)
    end

  end

end


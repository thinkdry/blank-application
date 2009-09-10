require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  controller = ApplicationController

  describe "default modules" do

    it "should include authenticated system"
    it "should include configuration"

  end

  describe "before filters" do

    it "should have a filter for checking if user is logged in" do
      controller.before_filters.should include(:is_logged?)
    end

    it "should have a filter for settings the locales" do
      controller.before_filters.should include(:set_locale)
    end

    it "should have a filter for setting default configuration" do
      controller.before_filters.should include(:get_configuration)
    end

  end

  describe "helper methods" do

    it "should make available all helpers to all controllers"
    it "should make available all application helper methods to all controllers"

  end

  describe "methods" do

    it "should check if current_user object exist" do
      logged_in?
    end

  end

end


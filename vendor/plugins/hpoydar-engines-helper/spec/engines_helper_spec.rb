require File.dirname(__FILE__) + '/spec_helper'

describe 'EnginesHelper' do
  
  # Setup a mock engines plugin
  before :all do
    @mock_plugin = 'engines-helper-mock'
    FileUtils.cp_r(
      File.dirname(__FILE__) + '/mock_plugin', 
      "#{RAILS_ROOT}/vendor/plugins/#{@mock_plugin}")
  end
  
  # Teardown
  after :all do
    FileUtils.rm_rf "#{RAILS_ROOT}/vendor/plugins/#{@mock_plugin}"
    FileUtils.rm_rf "#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}"
  end
  
  
  describe 'migrations' do
    
    before :all do
      @migrations = Dir.glob(
        "#{RAILS_ROOT}/vendor/plugins/#{@mock_plugin}/db/migrate/[0-9]*_*.rb").map { |migration|
        File.basename(migration)
      }
    end
    
    after :all do
      @migrations.each do |migration|
        FileUtils.rm_r "#{RAILS_ROOT}/db/migrate/#{migration}"
      end
    end
    
    it "should sync up the migrations when the rake task is run" do
      system "cd #{RAILS_ROOT} && rake engines:sync:migrations PLUGINS=#{@mock_plugin} -s"
      @migrations.each do |migration|
        File.exist?("#{RAILS_ROOT}/db/migrate/#{migration}").should be_true
      end
    end
    
  end
  
  describe 'asset management' do
    
    before :all do
      @assets = %w(images/engines_helper_mock.png javascripts/engines_helper_mock.js stylesheets/engines_helper_mock.css)
    end
    
    describe 'with autoload_assets true' do
      
      before :all do
        EnginesHelper.autoload_assets = true
        EnginesHelper::Assets.propagate
      end
      
      it "should autoload assets" do
        File.exist?("#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/#{@mock_plugin}").should be_true
        @assets.each do |asset|
          File.exist?("#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/#{@mock_plugin}/#{asset}").should be_true
        end
      end
    
    end
    
    describe 'with autoload_assets false' do
      
      # Force autoload_assets to false by sticking
      # in a temporary initializer for this spec run
      
      before :all do
        FileUtils.cp(
          File.dirname(__FILE__) + '/mock_initializers/autoload_assets_false.rb', 
          "#{RAILS_ROOT}/config/initializers/engines_helper_spec_run.rb")
      end
      
      after :all do
        FileUtils.rm_rf "#{RAILS_ROOT}/config/initializers/engines_helper_spec_run.rb"
        @assets.each do |asset|
          FileUtils.rm_r "#{RAILS_ROOT}/public/#{asset}"
        end
      end
      
      it "should sync up the assets when the rake task is run" do
        system "cd #{RAILS_ROOT} && rake engines:sync:assets -s"
        @assets.each do |asset|
          File.exist?("#{RAILS_ROOT}/public/#{asset}").should be_true
        end
      end
      
    end
    
  end
  
  describe 'asset helpers' do
    include ActionView::Helpers
    
    describe '#image_tag' do
      it "should use the plugin path when the :plugin option is set" do
        image_tag( 'engines_helper_mock.png', :plugin => @mock_plugin ).should =~ /src="\/#{EnginesHelper.plugin_assets_directory}\/#{@mock_plugin}\/images\/engines_helper_mock.png/
      end
    end
    
    describe '#javascript_include_tag' do
      it "should use the plugin path when the :plugin option is set" do
        javascript_include_tag( 'engines_helper_mock', :plugin => @mock_plugin ).should =~ /src="\/#{EnginesHelper.plugin_assets_directory}\/#{@mock_plugin}\/javascripts\/engines_helper_mock.js/
      end
    end
    
    describe '#stylesheet_link_tag' do
      it "should use the plugin path when the :plugin option is set" do
        stylesheet_link_tag( 'engines_helper_mock', :plugin => @mock_plugin ).should =~ /href="\/#{EnginesHelper.plugin_assets_directory}\/#{@mock_plugin}\/stylesheets\/engines_helper_mock.css/
      end
    end
  
  end
  
  
end
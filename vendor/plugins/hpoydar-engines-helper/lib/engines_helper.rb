module EnginesHelper

  # Configuration and defaults
  
  mattr_accessor :autoload_assets
  self.autoload_assets = true
  
  mattr_accessor :plugin_assets_directory
  self.plugin_assets_directory = 'plugin_assets'
 
end

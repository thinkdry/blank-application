#
# These helpers are right out of the original Engines plugin
#

module EnginesHelper::RailsExtensions::AssetHelpers
  def self.included(base) #:nodoc:
    base.class_eval do
      [:stylesheet_link_tag, :javascript_include_tag, :image_path, :image_tag].each do |m|
        alias_method_chain m, :engine_additions
      end
    end
  end

  # Adds plugin functionality to Rails' default stylesheet_link_tag method.
  def stylesheet_link_tag_with_engine_additions(*sources)
    stylesheet_link_tag_without_engine_additions(*EnginesHelper::RailsExtensions::AssetHelpers.pluginify_sources("stylesheets", *sources))
  end

  # Adds plugin functionality to Rails' default javascript_include_tag method.  
  def javascript_include_tag_with_engine_additions(*sources)
    javascript_include_tag_without_engine_additions(*EnginesHelper::RailsExtensions::AssetHelpers.pluginify_sources("javascripts", *sources))
  end

  #
  # Our modified image_path now takes a 'plugin' option, though it doesn't require it
  #

  # Adds plugin functionality to Rails' default image_path method.
  def image_path_with_engine_additions(source, options={})
    options.stringify_keys!
    source = EnginesHelper::RailsExtensions::AssetHelpers.plugin_asset_path(options["plugin"], "images", source) if options["plugin"]
    image_path_without_engine_additions(source)
  end

  # Adds plugin functionality to Rails' default image_tag method.
  def image_tag_with_engine_additions(source, options={})
    options.stringify_keys!
    if options["plugin"]
      source = EnginesHelper::RailsExtensions::AssetHelpers.plugin_asset_path(options["plugin"], "images", source)
      options.delete("plugin")
    end
    image_tag_without_engine_additions(source, options)
  end

  #
  # The following are methods on this module directly because of the weird-freaky way
  # Rails creates the helper instance that views actually get
  #

  # Convert sources to the paths for the given plugin, if any plugin option is given
  def self.pluginify_sources(type, *sources)
    options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }
    sources.map! { |s| plugin_asset_path(options["plugin"], type, s) } if options["plugin"]
    options.delete("plugin") # we don't want it appearing in the HTML
    sources << options # re-add options      
  end  

  # Returns the publicly-addressable relative URI for the given asset, type and plugin
  def self.plugin_asset_path(plugin_name, type, asset)
    #raise "No plugin called '#{plugin_name}' - please use the full name of a loaded plugin." if !File.exist?("#{RAILS_ROOT}/public/plugin_assets/#{plugin_name}/#{type}/#{asset}")
    "/plugin_assets/#{plugin_name}/#{type}/#{asset}"
  end
  
end

module ::ActionView::Helpers::AssetTagHelper
  include EnginesHelper::RailsExtensions::AssetHelpers
end
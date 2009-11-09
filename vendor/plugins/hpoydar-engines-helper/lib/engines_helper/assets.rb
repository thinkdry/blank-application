module EnginesHelper::Assets
  extend self

  # Propagate the public folders
  def propagate
    return if !EnginesHelper.autoload_assets
    plugin_list.each do |plugin|
      FileUtils.mkdir_p "#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/#{plugin}"
      Dir.glob("#{RAILS_ROOT}/blank_modules/#{plugin}/public/*").each do |asset_path|
        FileUtils.cp_r(asset_path, "#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/#{plugin}/.")
      end
    end
  end
  
  def update_sass_directories
    
    if check_for_sass
      
      unless Sass::Plugin.options[:template_location].is_a?(Hash)
        Sass::Plugin.options[:template_location] = {
        Sass::Plugin.options[:template_location] => Sass::Plugin.options[:template_location].gsub(/\/sass$/, '') }
      end
      
      Dir.glob("#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/**/sass") do |sass_dir|
        Sass::Plugin.options[:template_location] =
          Sass::Plugin.options[:template_location].merge({
          sass_dir => sass_dir.gsub(/\/sass$/, '')
        })
      end
    
    end
  end
  
private
  
  def plugin_list
    Dir.glob("#{RAILS_ROOT}/blank_modules/*").reject { |p| 
      !File.exist?("#{RAILS_ROOT}/blank_modules/#{File.basename(p)}/public") 
    }.map { |d| File.basename(d) }
  end
  
  def check_for_sass
    defined?(Sass) && Sass.version[:major]*10 + Sass.version[:minor] >= 21
  end

end

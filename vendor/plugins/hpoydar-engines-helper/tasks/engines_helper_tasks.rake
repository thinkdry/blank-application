namespace :engines do
  namespace :sync do
    
    desc "Sync all plugin migrations to the parent application"
    task :migrations do
    
      unless RAILS_ENV == 'test'
        puts ""
        puts "Syncing migrations ..."
        puts ""
      end
      
      system "mkdir -p db/migrate"
      
      if ENV['PLUGINS'] 
        plugin_list = ENV['PLUGINS'].split(',').map{ |n| File.dirname(__FILE__) + '/../../' + n.strip }
      else
        plugin_list = Dir.glob(File.dirname(__FILE__) + '/../../*')
      end
      
      plugin_list.each do |plugin|
        raise "Plugin #{plugin} does not exist" if !File.exist?(plugin)
        Dir.glob(plugin + '/db/migrate/[0-9]*_*.rb') do |migration|
          puts "Syncing #{File.basename(plugin)} migration #{File.basename(migration)}" unless RAILS_ENV == 'test'
          system "rsync -u #{migration} db/migrate"
        end
      end
      
      unless RAILS_ENV == 'test'
        puts ""
        puts "Sync complete. (You will still need to run the migrations.)"
        puts ""
      end
  
    end
    
    desc "Sync all plugin migrations to the parent application"
    task :assets => :environment do
    
      if EnginesHelper.autoload_assets 
        puts ""
        puts "Syncing of plugin assets will happen automatically when the application loads."
        puts "To disable this behavior and sync the plugin public folders with the"
        puts "parent application on demand with this rake task, set"
        puts "EnginesHelper.autoload_assets = false in environment.rb."
        puts ""
        exit
      end
    
      unless RAILS_ENV == 'test'
        puts ""
        puts "Syncing assets ..."
        puts ""
      end
        
      system "mkdir -p public"
      Dir.glob(File.dirname(__FILE__) + '/../../*').each do |plugin|
        if File.exist?("#{plugin}/public")
          puts "Syncing #{File.basename(plugin)} public folder" unless RAILS_ENV == 'test'
          system "rsync -ru #{plugin}/public ."
        end
      end
      
      unless RAILS_ENV == 'test'
        puts ""
        puts "Sync complete."
        puts ""
      end
  
    end
    
  end
end
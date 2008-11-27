server = ENV['SERVER'] || ENV['RAILS_ENV']
server ||= 'production'

set :application, "blank"

set :use_sudo, false

# GitHub repository
set :repository, "thinkdry@dev.thinkdry.com:/home/git/blank.git"
set :scm, :git
# The git repository is cloned to a temp directory
# => This folder is copied and pulled on update_code task
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }

set :user, 'thinkdry'

#set :deploy_to, "/home/rails/#{application}"

if (server == 'development')
	set :deploy_to, "/home/rails/#{application}_dev"
  set :rails_env, 'development'
  set :branch, "master" 
  server "dev.thinkdry.com", :app, :web, :db, :primary => true
elsif (server == 'production')
	set :deploy_to, "/home/rails/#{application}"
  set :rails_env, 'production'
  set :branch, "master"
  server "dev.thinkdry.com", :app, :web, :db, :primary => true
end

namespace :deploy do
  
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t.to_s.capitalize} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Link shared folders into release_path"
  task :link_shared_folders, :roles => :app do
    run <<-CMD
      ln -s #{shared_path}/public/artic_file    #{latest_release}/public/artic_file &&
      ln -s #{shared_path}/public/article_file  #{latest_release}/public/article_file &&
      ln -s #{shared_path}/public/audio         #{latest_release}/public/audio &&
      ln -s #{shared_path}/public/image         #{latest_release}/public/image &&
      ln -s #{shared_path}/public/publication   #{latest_release}/public/publication &&
      ln -s #{shared_path}/public/user          #{latest_release}/public/user &&
      ln -s #{shared_path}/public/video         #{latest_release}/public/video &&
      ln -s #{shared_path}/public/uploads       #{latest_release}/public/uploads &&
			ln -s #{shared_path}/public/picture       #{latest_release}/public/picture
    CMD
  end
  after "deploy:update_code", "deploy:link_shared_folders"
  
  desc "Copy config files (database.yml) into release path"
  task :copy_config_files do
    #run "cp #{shared_path}/config/* #{release_path}/config/"
		run "mv #{release_path}/config/database_sample.yml #{release_path}/config/database.yml"
  end
  after "deploy:update_code", "deploy:copy_config_files"
  
  desc "Run spec tests"
  task :spec, :roles => :app do
    run "cd #{release_path} && rake db:migrate RAILS_ENV=test && spec spec -f s"
  end
  after "deploy:update_code", "deploy:spec"
  
  desc "Create shared folders"
  task :create_shared_folders, :roles => :app do
    run <<-CMD
      mkdir -p #{shared_path}/public/artic_file/file_path/tmp &&
      mkdir -p #{shared_path}/public/article_file/file_path/tmp &&
      mkdir -p #{shared_path}/public/audio/file_path/tmp &&
      mkdir -p #{shared_path}/public/image/file_path/tmp &&
      mkdir -p #{shared_path}/public/publication/file_path/tmp &&
      mkdir -p #{shared_path}/public/user/image_path/tmp &&
      mkdir -p #{shared_path}/public/video/file_path/tmp &&
      mkdir -p #{shared_path}/public/uploads &&
			mkdir -p #{shared_path}/public/picture/picture_path/tmp
    CMD
  end
  after "deploy:init", "deploy:create_shared_folders"
  
  desc "Create shared/config directory and default database.yml."
  task :create_shared_config do
    run "mkdir -p #{shared_path}/config"

    upload(File.dirname(__FILE__) + '/database_sample.yml', "#{shared_path}/config/database.yml")
    puts "Please edit database.yml in the shared directory."
  end
  after "deploy:init", "deploy:create_shared_config"
  
  desc "Create XAPIAN index"
  task :create_xapian_index do
    run "cd #{release_path} && rake xapian:rebuild_index models='ArticFile Article Audio Image Publication Video FeedSource Link' RAILS_ENV=#{server}"
    run "cd #{release_path} && rake xapian:update_index RAILS_ENV=#{server}"
  end
  after "deploy:migrate", "deploy:create_xapian_index"
end

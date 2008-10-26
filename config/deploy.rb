server = ENV['SERVER'] || ENV['RAILS_ENV']
server ||= 'development'

set :application, "artic"

set :use_sudo, false

# GitHub repository
set :repository,  "git@github.com:yvon/artic.git"
set :scm, :git
# The git repository is cloned to a temp directory
# => This folder is copied and pulled on update_code task
set :deploy_via, :remote_cache

set :user, 'thinkdry'

set :deploy_to, "/home/rails/#{application}"

if (server == 'development')
  set :rails_env, 'development'
  set :branch, "master" 
  server "dev.thinkdry.com", :app, :web, :db, :primary => true
elsif (server == 'production')
  set :rails_env, 'production'
  set :branch, "release"
  server "prod.thinkdry.com", :app, :web, :db, :primary => true
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
      ln -s #{shared_path}/public/uploads       #{latest_release}/public/uploads
    CMD
  end
  after "deploy:update_code", "deploy:link_shared_folders"
  
  desc "Copy config files (database.yml) into release path"
  task :copy_config_files do
    run "cp #{shared_path}/config/* #{release_path}/config/"
  end
  after "deploy:update_code", "deploy:copy_config_files"
  
  desc "Create shared folders"
  task :create_shared_folders, :roles => :app do
    run <<-CMD
      mkdir -p #{shared_path}/public/artic_file &&
      mkdir -p #{shared_path}/public/article_file &&
      mkdir -p #{shared_path}/public/audio &&
      mkdir -p #{shared_path}/public/image &&
      mkdir -p #{shared_path}/public/publication &&
      mkdir -p #{shared_path}/public/user &&
      mkdir -p #{shared_path}/public/video &&
      mkdir -p #{shared_path}/public/uploads
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
end

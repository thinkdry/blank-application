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
end

namespace :config do
  
  desc "Copy config files"
  task :copy_config_files do
    run "cp #{shared_path}/config/* #{release_path}/config/"
  end
  after "deploy:update_code", "config:copy_config_files"

  desc "Create shared/config directory and default database.yml."
  task :create_shared_config do
    run "mkdir -p #{shared_path}/config"

    upload(File.dirname(__FILE__) + '/database_sample.yml', "#{shared_path}/config/database.yml")
    puts "Please edit database.yml in the shared directory."
  end
end

namespace :db do
  
  desc "Reset DB and load fixtures"
  task :reset do    
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate:reset && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:fixtures:load"
  end
  
end
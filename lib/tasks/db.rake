namespace :db do
	
  desc "Dump the current database to a MySQL file"
  task :database_dump do
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    case abcs[RAILS_ENV]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
      File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
        if abcs[RAILS_ENV]["password"].blank?
					# -h #{abcs[RAILS_ENV]["host"]}
          f << `mysqldump -u #{abcs[RAILS_ENV]["username"]} #{abcs[RAILS_ENV]["database"]}`
        else
          f << `mysqldump -u #{abcs[RAILS_ENV]["username"]} -p#{abcs[RAILS_ENV]["password"]} #{abcs[RAILS_ENV]["database"]}`
        end
      end
    else
      raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'"
    end
  end

  desc "Refreshes your local development environment to the current production database"
  task :production_data_refresh do
    `cap dump:remote_db_runner`
    `rake db:dump_file_data_load --trace`
  end

  desc "Loads the production data downloaded into db/production_data.sql into your local development database"
  task :dump_file_data_load do
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    case abcs[RAILS_ENV]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
      if abcs[RAILS_ENV]["password"].blank?
				# -h #{abcs[RAILS_ENV]["host"]}
        `mysql -u #{abcs[RAILS_ENV]["username"]} #{abcs[RAILS_ENV]["database"]} < db/#{RAILS_ENV}_data.sql`
      else
        `mysql -u #{abcs[RAILS_ENV]["username"]} -p#{abcs[RAILS_ENV]["password"]} #{abcs[RAILS_ENV]["database"]} < db/#{RAILS_ENV}_data.sql`
      end
    else
      raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'"
    end
  end

end

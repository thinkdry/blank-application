namespace :blank do

	desc "Initializing Blank Engine"
	task(:init => :environment) do
		p "===== ENVIRONMENT : "+RAILS_ENV
		Rake::Task['blank:captcha'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['blank:xapian_create'].invoke
		p "Restarting BackgroundRB daemon ..."
		system("./script/backgroundrb stop -e #{RAILS_ENV}")
		system("./script/backgroundrb start -e #{RAILS_ENV}")
		p "Done."
	end

	desc "Run Production Log Analyzer"
	task(:planalyze => :environment) do
		system("pl_analyze log/#{RAILS_ENV}.log")
    #		require 'production_log/analyzer'
    #		p "Beginning production logs analysis ..."
    #		a = Analyzer.new('log/production.log')
    #		a.process
    #		# See also a.db_times and a.render_times
    #		a.request_times.map do |resource, times|
    #			next if resource.nil?
    #			# times is an array of floats for each
    #			# request to the resource.
    #			# Here is where you would save some values
    #			# to the database.
    #			puts "#{resource} => #{times.join(", ")}"
    #		end
	end

	desc "Building Xapian indexes"
	task(:xapian_create => :environment) do
		p "Building Xapian indexes ......"
		system("rake xapian:rebuild_index models='#{ITEMS.map{ |e| e.camelize }.join(' ')} User Workspace' RAILS_ENV=#{RAILS_ENV}")
		#Rake::Task['xapian:rebuild_index'].invoke("models=\"#{ITEMS.map{ |e| e.camelize }.join(' ')} User Workspace\"")
		p "Done"
	end

	desc "Checking Captcha images"
	task(:captcha => :environment) do
		if File.exists?(RAILS_ROOT+'/public/images/captcha/')
			if Dir.entries(RAILS_ROOT+'/public/images/captcha/').size < 10
				p "Generating the Catcha images ......"
				system('rake yacaph:generate COUNT=10')
				p "done"
			else
				p "Captcha images already generated"
			end
		else
			p "Generating the Catcha images ......"
			system('rake yacaph:generate COUNT=10')
			p "done"
		end
	end

  
end

#insert into roles(id, name, description, type_role, created_at, updated_at)values(1, 'superadmin', 'SuperAdministration', 'system' CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);",
#"insert into workspaces(id, creator_id, description, title, state, created_at, updated_at, ws_config_id)values(1, 1, 'Private Workspace for BOSS', 'Private for Boss', 'private', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,1);"
#    Accept User names from console
#    sa_user=STDIN.gets.chomp
#    sa_user="boss" if sa_user.blank?
#    p "Setting Up #{sa_user} as Superadmin"
namespace :debugging do

	desc "Run Production Log Analyzer"
	task :planalyze => :environment do
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

	desc "Print the end of the current environment log file"
	task :tail_logs => :environment do
		system("tail -n 300 log/#{RAILS_ENV}.log")
	end

end

namespace :backgroundrb do

	desc "Restarting BackgroundRB"
	task :restart => :environment do
		p "Restarting BackgroundRB daemon ..."
		system("./script/backgroundrb stop -e #{RAILS_ENV}")
		system("./script/backgroundrb start -e #{RAILS_ENV}")
		p "Done."
	end

end

namespace :captcha do

	desc "Checking Captcha images"
	task :generate => :environment do
		if File.exists?(RAILS_ROOT+'/public/images/captcha/')
			if Dir.entries(RAILS_ROOT+'/public/images/captcha/').size < CAPTCHA_IMAGES_NUMBER
				p "Generating the Catcha images ......"
				system("rake yacaph:generate COUNT=#{CAPTCHA_IMAGES_NUMBER}")
				p "done"
			else
				p "Captcha images already generated"
			end
		else
			p "Generating the Catcha images ......"
			system("rake yacaph:generate COUNT=#{CAPTCHA_IMAGES_NUMBER}")
			p "done"
		end
	end

end
class Superadmin::TasksController < Admin::ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	# Action managing the list of tasks available
	#
	# Usage URL :
	# - GET  /admin/tasks
	def index
		
	end

	# Action running the task selected (used with AJAX call)
	#
	# Usage URL :
	# - GET  /admin/tasks/run_task?job=xapian
	def run_task
		if params[:job] == 'xapian'
			system("rake xapian:update_index RAILS_ENV=#{RAILS_ENV}")
		end
		if params[:job] == 'feeds'
			system("ruby script/runner -e #{RAILS_ENV} 'FeedSource.update_feed_source'")
		end
		if params[:job] == 'newsletter'
			Delayed::Job.enqueue(NewsletterJob.new)
		end
		if params[:job] == 'translations'
			LANGUAGES.each do |l|
				command_backup =  "mv config/locales/" + l + ".yml tmp/backup/" + Time.now.strftime("%Y%m%d") + "_" + l + ".yml"
				command_get =  "wget " + TRANSLATION_SITE + "/translations/" + PROJECT_NAME + "/" + l + ".yaml -O config/locales/" + l + ".yml"
				system(command_backup)
				system(command_get)
			end
			message = "Translation files Retrieved"
		end
		if params[:job] == 'restart_server'
			system "touch #{RAILS_ROOT}/tmp/restart.txt" # tells passenger to restart the server
			message = "Server restarted successfully"
		end
		render :update do |page|
      page.show 'notice'
			page.replace_html 'notice', message.nil? ? "#{params[:job].capitalize} Updated Sucessfully " : message
		end
  end

end

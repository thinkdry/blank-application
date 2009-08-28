class Admin::TasksController < ApplicationController

	before_filter :is_superadmin?

	def index
		
	end

 def run_task
   if params[:job] == 'xapian'
     MiddleMan.worker(:cronjob_worker).update_xapian_index
   end
   if params[:job] == 'feeds'
     MiddleMan.worker(:cronjob_worker).update_feed_source
   end
   if params[:job] == 'newsletter'
     MiddleMan.worker(:cronjob_worker).send_newsletter
   end
   if params[:job] == 'restart_server'
     system "touch #{RAILS_ROOT}/tmp/restart.txt" # tells passenger to restart the
     message = "Server restarted successfully"
   end
   render :update do |page|
     page.call 'alert', message.nil? ? "#{params[:job]} Updated Sucessfully " : message
   end
 end

end

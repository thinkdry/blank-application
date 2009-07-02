class HomeController < ApplicationController 
  
  # HomePage of the Blank Application
  #
  # Root page ('/')
  #
  def index
    @latest_items = GenericItem.consultable_by(current_user.id).latest
    @latest_users = User.latest
    @latest_feeds = current_user.feed_items.latest
    @latest_ws = Workspace.allowed_user_with_permission(@current_user.id, 'workspace_show').all(:order => 'created_at DESC', :limit => 5)
		@accordion=[@latest_items,@latest_users,@latest_feeds,@latest_ws]
  end

  # Method for Autocomplete on Users
  #
  # /home/autocomplete_on
  #
	def autocomplete_on
		#params[:object_name]
		conditions = if params[:name]
       ["name LIKE :name", { :name => "%#{params['name']}%"} ]
     else
       {}
     end
		 @objects=params[:model_name].classify.constantize.find(:all, :conditions => conditions)
		 render :text => '<ul>'+@objects.map{ |e| '<li>'+e.name+'</li>' }.join(' ')+'</ul>'
	end

end

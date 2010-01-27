class Admin::NotificationsController < Admin::ApplicationController
  
  before_filter  :get_user, :check_system_permission
  #
  # Select a list of objects and actions for user to be notified when updates are done on theses objects 
  #
  def index
    allowed_items =  get_allowed_item_types(current_container)
    @actions = NotificationFilter.actions
    #select just allowed objects in configuration 
    @models =  NotificationFilter.models.delete_if{ |m| !allowed_items.include?(m.name) }    
    @filters  = @user.notification_filters || {}
  end

  def create
    filters  = @user.notification_filters.delete_all 
    if params[:notification_filters]
		  params[:notification_filters].each do |k, v|
		    @user.notification_filters << NotificationFilter.find(k.to_i)
		  end
		end
    #TODO Translation
		flash[:notice] = 'Les modifications ont été éffectuées avec succès'
		redirect_to admin_user_notifications_path(@user)
  end

  protected

  def check_system_permission
    if current_user.has_system_permission('user','edit') || current_user.id == @user.id
      return true
    else  
      no_permission_redirection
    end
  end
  
  def get_user
    @user = User.find(params[:user_id])
  end
    

end

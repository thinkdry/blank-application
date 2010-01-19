class Admin::SubscriptionsController < Admin::ApplicationController

  def create
    if current_container.users_containers.create(:user_id => current_user.id, :role_id => Role.find_by_name('reader').id)
      flash[:notice] = I18n.t("#{current_container.label_name}.subscription.flash_notice")
      redirect_to container_path(current_container)
    else
      flash[:error] = I18n.t("#{current_container.label_name}.subscription.flash_error")
      redirect_to container_path(current_container)
    end
  end
  
  def destroy
    if current_container.users_containers.find(:first, :conditions => { :user_id => current_user.id }).destroy
      flash[:notice] = I18n.t("#{current_container.label_name}.unsubscription.flash_notice")
      redirect_to container_path(current_user.private_workspace)
    else
      flash[:error] = I18n.t("#{current_container.label_name}.unsubscription.flash_error")
      redirect_to container_path(current_container)
    end
  end
  
  def request_subscription #:nodoc:
    if UserMailer.deliver_ws_administrator_request(current_container.creator, current_user.id, params[:question][:type], params[:question][:msg])
      flash[:notice] = I18n.t("#{current_container.label_name}.question.flash_notice")
      redirect_to container_path(current_container)
    else
      flash[:error] = I18n.t("#{current_container.label_name}.question.flash_error")
      redirect_to container_path(current_container)
    end
  end

end

class UserObserver < ActiveRecord::Observer
	
  def after_save(user)
    UserMailer.deliver_reset_notification(user) if user.recently_reset?
  end
end

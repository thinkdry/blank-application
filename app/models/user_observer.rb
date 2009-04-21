class UserObserver < ActiveRecord::Observer

	include Configuration

	def after_create(user)
		if is_mandatory_user_activation?
			UserMailer.deliver_signup_notification(user)
		else
			user.activated_at = Time.now
			user.save
		end
	end

  def after_save(user)
    UserMailer.deliver_reset_notification(user) if user.recently_reset?
  end
	
end

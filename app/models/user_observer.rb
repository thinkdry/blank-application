class UserObserver < ActiveRecord::Observer

	include Configuration

  # Check System Configuration for Sending Activation Mail to User
	def after_create(user)
		get_configuration
		if is_mandatory_user_activation?
			UserMailer.deliver_signup_notification(user)
		else
			user.activated_at = Time.now
			user.save
		end
	end

  # After Save Send User Notifiction for recently Set
  def after_save(user)
    UserMailer.deliver_reset_notification(user) if user.recently_reset?
  end
	
end

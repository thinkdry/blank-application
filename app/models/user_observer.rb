# This observer is in charge to manage some actions relative to users.
#
class UserObserver < ActiveRecord::Observer 

	# Library included to get the application configuration methods
	include Configuration

  # Sending Activation Mail to User
  #
  # This method will send signup notification mail if the user activation mandatory,
	#  else it will just activate directly the user.
  #
  # Parameter :
  # - user: User instance
	def after_create(user)
		get_configuration
		if is_mandatory_user_activation?
			UserMailer.deliver_signup_notification(user)
		else
			user.activated_at = Time.now
			user.save
		end
	end

  # Deliver Reset Notification
  #
  # This method will check the User object after each databse save on it,
	# and so deliver a reset notification if the user have asked a reset request.
	#
	# Parameter :
  # - user: User instance
  def after_save(user)
    UserMailer.deliver_reset_notification(user) if user.recently_reset?
  end
	
end

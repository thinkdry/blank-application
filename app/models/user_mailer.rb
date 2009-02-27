class UserMailer < ActionMailer::Base
	
	def daurl
		return get_sa_config[:sa_application_url]
  end

	def site_name
		return get_sa_config[:sa_application_name]
	end

	def contact_email
		return get_sa_config[:sa_contact_email]
	end
	
	def signup_notification(user)
		setup_email(user)
		subject self.site_name+" : Ouverture de compte"
		body :url => self.daurl+"/activate/#{user.activation_code}",
			:site => self.site_name,
			:user_login => user.login,
			:user_password => user.password
  end
	
  def reset_notification(user)
		setup_email(user)
		subject self.site_name+" : Mot de passe oublié"
		body :url => self.daurl+"/reset_password/#{user.password_reset_code}",
			:user_login => user.login,
			:site => self.site_name
  end

	def ws_administrator_request(admin, user, type, msg)
		setup_email(User.find(admin))
		from User.find(user).email
		subject self.site_name+" : "+type
		body :msg => msg
  end
   
  protected
    def setup_email(user)
      recipients user.email
      from self.contact_email
      sent_on Time.now
    end
		
end

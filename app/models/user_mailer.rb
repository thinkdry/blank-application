class UserMailer < ActionMailer::Base
	
	def daurl
		return "http://localhost:3000"
  end
	
	def invitation_notification(user)
		setup_email(user)
		@subject += "Invitation d'ouverture de compte"
		@body[:url] = self.daurl+"/invitation/#{user.invitation_code}"
  end
	
  def reset_notification(user)
     setup_email(user)
     @subject += 'Mot de passe oublié'
     @body[:url] = self.daurl+"/reset_password/#{user.password_reset_code}"
  end
  
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "contact@artic-institut.com"
      @subject     = "ARTIC : "
      @sent_on     = Time.now
      @body[:user] = user
    end
		
end

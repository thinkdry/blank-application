# This controller handles the functions relative to the session of a logged user.
#
class SessionsController < ApplicationController

	# Filter skipping the authentication for the following action, except for 'destroy' and 'change_language' actions.
  skip_before_filter :is_logged?, :except => [:destroy, :change_language]

	# To overwrite the layout define inside 'application_controller.rb' with the login layout.
  layout 'login'

	# Session creation
	#
  # This function is creating a new session for given login and password,
	# or if the uthentication is not proved, it is redirecting on le login page.
	#
	# Usage URL :
	# - /login
	#
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user && user.activated_at
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = I18n.t('user.session.flash_notice')
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash[:error] = I18n.t('user.session.flash_error')
      render :action => 'new'
       
    end
  end

  # Session deletion
	#
	# 
  # 
  # Usage URL :
  # 
  # /logout
  #
  def destroy
    User.find(current_user.id).update_attributes(:last_connected_at => Time.now)
    logout_killing_session!
    flash[:notice] = "Vous avez été déconnecté"
    redirect_back_or_default('/')
  end

  # Change Language Option for Current User
  #
  # Usage URL
  #
  # /session/change_language
  #
	def change_language
    current_user.update_attributes(:u_language => params[:locale])
		render(:update) { |page| page.call 'location.reload' }
		#redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Impossible de vous connecter en tant que '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end

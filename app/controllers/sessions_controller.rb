# This controller handles the functions relative to the session of a logged user.
#
class SessionsController < ApplicationController

	# Filter skipping the authentication for the following action, except for 'destroy' and 'change_language' actions.
  skip_before_filter :is_logged?, :except => [:destroy, :change_language]

	# To overwrite the layout define inside 'application_controller.rb' with the login layout.
  layout 'login'

	# Action managing session creation
	#
  # This function is creating a new session for given login and password,
	# or if the uthentication is not proved, it is redirecting on le login page.
	#
	# Usage URL :
	# - GET /login
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
      flash[:error] =  I18n.t('user.session.login_error')+ ' '+ params[:login]
			logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash.now[:error] = I18n.t('user.session.flash_error')
      render :action => 'new'
    end
  end

  # Action managing session deletion
	#
	# This function is destroying the session of the current user, updating his 'last_connected_at' field,
	# and redirecting on the root page.
	#
  # Usage URL :
  # - GET /logout
  def destroy
    User.find(current_user.id).update_attributes(:last_connected_at => Time.now)
    logout_killing_session!
    flash[:notice] = I18n.t('user.session.logout_notice')
    redirect_back_or_default('/')
  end

  # Action updating the current language
  #
  # This function analyze the paramater 'locale' and set from it the new locale for the current user.
  #
	# Usage URL :
  # - GET /session/change_language
	def change_language
		if params[:hl]
			session[:hl] = params[:hl]
		end
		if params[:via_google_trans] && params[:hl]
			redirect_to "http://translate.google.com/translate?u=#{request.url.split('?').first}&sl=fr&tl=#{params[:hl]}"
		else
			render(:update) { |page| page.call 'location.reload' }
		end
  end

end

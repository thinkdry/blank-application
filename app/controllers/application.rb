# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	helper_method :available_items_list, :available_languages, :get_current_config, :right_conf
  before_filter :is_logged?
	before_filter :set_locale

	include AuthenticatedSystem

	include ActsAsItem::UrlHelpers
	#include ActsAsItem::HelperMethods
	
	def is_logged?
    if logged_in?
      return true
    else
      redirect_to login_path
    end
  end

	def available_items_list
		if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
			return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")["sa_items"]
		else
			return []
		end
	end

	def available_languages
		if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
			return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")["sa_languages"]
		else
			return []
		end
	end

	def get_sa_config
		if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
			return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
		else
			return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
		end
	end

	def get_current_config(ws_id=1)
		# TODO to find a solution to know where we are
		if (Workspace.exists?(params[:id]))
			if (ws=Workspace.find(params[:id])).ws_config
				ws_id = ws.ws_config
			else
				ws_id = 1
			end
		end
		return WsConfig.find(ws_id)
	end

	def is_superadmin?
		no_permission_redirection unless self.current_user.has_role('superadmin')
	end

	def no_permission_redirection
		flash[:error] = "Permission denied"
		redirect_to '/'
	end


	private
  
	def check_to_tab(param)
		@list = params[param.to_sym]
		res = []
		if @list
			@list.each do |k, v|
				res << k.to_s
			end
		end
		res
	end

  def set_locale
		if params[:locale]
			I18n.locale = params[:locale]
		elsif session[:locale]
			I18n.locale = session[:locale]
		else
			I18n.locale = I18n.default_locale
		end
  end

end

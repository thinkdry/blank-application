# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	helper_method :available_items_list, :available_languages, :get_sa_config, :get_current_items, :right_conf, :is_allowed_free_user_creation?
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

	def is_allowed_free_user_creation?
		return get_sa_config['sa_allowed_free_user_creation']=='true'
	end

	def is_given_private_workspace
		return get_sa_config['automatic_private_workspace']=='true'
	end

	def available_items_list
		return get_sa_config['sa_items']
	end

	def available_languages
		return get_sa_config['sa_languages']
	end

	def get_sa_config
		if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
			return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
		else
			return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
		end
	end

	def get_current_items
		# TODO to find a solution to know where we are
		if (Workspace.exists?(params[:id]))
			return Workspace.find(params[:id]).ws_items.split(',')
		else
			return get_sa_config['sa_items']
		end
	end

	def is_superadmin?
		no_permission_redirection unless self.current_user.has_system_role('superadmin')
	end

	def is_admin?
		no_permission_redirection unless self.current_user.has_system_role('admin')
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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"
require 'rubygems'
require 'RMagick'

class ApplicationController < ActionController::Base
  
  IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"]
  
  helper :all # include all helpers, all the time
	helper_method :available_items_list, :available_languages, :get_sa_config, :right_conf, :is_allowed_free_user_creation?
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

  def upload_photo(photo, crop_width, crop_height, path_name)
    photo.rewind
    pic = Magick::Image.from_blob(photo.read)[0]
    width = pic.columns
     height = pic.rows
     if (width > height)
       pic.scale!((crop_width/width.to_f))
     else
       pic.scale!((crop_height/height.to_f))
     end
#     back = Magick::Image.new(crop_width,crop_height) {
#						 self.background_color = 'white'
##						 self.format = 'JPG'
#					 }
     pic.composite!(pic, Magick::CenterGravity, Magick::InCompositeOp)
     File.open(RAILS_ROOT + path_name, "wb") do |f|
			f.write(pic.to_blob)
     end
  end

end

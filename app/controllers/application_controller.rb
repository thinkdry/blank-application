# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"
require 'rubygems'
require 'RMagick'
#require 'json'

class ApplicationController < ActionController::Base
  include YacaphHelper
  IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"]
  
  helper :all # include all helpers, all the time
	helper_method :available_items_list, :available_languages, :get_sa_config, :right_conf,
		:is_allowed_free_user_creation?, :get_default_item_type, :item_types_allowed_to, :get_per_page_value, :admin?
  before_filter :is_logged?
	before_filter :set_locale

	include AuthenticatedSystem
	include Configuration
	include ActsAsItem::UrlHelpers
	
	def is_logged?
    if logged_in?
			@search ||= Search.new
      return true
    else
      redirect_to login_path
    end
  end

	def get_default_item_type
		if current_workspace
			return (current_workspace.ws_items.split(',') & get_sa_config['sa_items']).first.to_s.pluralize
		else
			return get_sa_config['sa_items'].first.to_s.pluralize
		end
	end

	def item_types_allowed_to(user, action)
		if current_workspace
			(current_workspace.ws_items.split(',') & get_sa_config['sa_items']).delete_if{ |e| !user.has_workspace_permission(current_workspace.id, e, action) }
		else
			available_items_list.delete_if{ |e| Workspace.allowed_user_with_permission(user.id, e+'_'+action).size == 0 }
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

	def get_item_list(item_type)
		if !item_type.blank?
			current_objects = item_type.camelize.classify.constantize.list_items_with_permission_for(@current_user, 'show', current_workspace)
			if params[:filter_name]
				params[:filter_way] ||= 'desc'
				if params[:filter_way] == 'desc'
					current_objects = current_objects.sort{ |x, y| y.send(params[:filter_name].to_sym) <=> x.send(params[:filter_name].to_sym) }
				else
					current_objects = current_objects.sort{ |x, y| x.send(params[:filter_name].to_sym) <=> y.send(params[:filter_name].to_sym) }
				end
			end
			return current_objects
		else
			return []
		end
	end

	def admin?
		true
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
		I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
		session[:locale] = I18n.locale
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

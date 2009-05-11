# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "acts_as_item/url_helpers.rb"
require 'rubygems'
require 'RMagick'

class ApplicationController < ActionController::Base

	include AuthenticatedSystem
	include ExceptionNotifiable
	# local_addresses.clear # always send email notifications instead of displaying the error
	include Configuration
	include ActsAsItem::UrlHelpers
	include YacaphHelper
  
  #layout 'app_fat_menu'
	layout :get_da_layout
  
  IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"]
  
  helper :all # include all helpers, all the time
	helper_method :available_items_list, :available_languages, :get_sa_config, :right_conf,
		:is_allowed_free_user_creation?, :get_allowed_item_types, :item_types_allowed_to, :get_per_page_value, :admin?, :groups_of_workspaces_of_item
  before_filter :is_logged?
	before_filter :set_locale
	before_filter :get_configuration
	
	
	def is_logged?
    if logged_in?
			@search ||= Search.new
      return true
    else
      redirect_to login_path
    end
  end

	def get_da_layout
		return @configuration['sa_layout'] || 'application'
	end

	def get_allowed_item_types(workspace=nil)
		if workspace
			return (workspace.ws_items.to_s.split(',') & @configuration['sa_items'])
		else
			return @configuration['sa_items']
		end
	end

	def item_types_allowed_to(user, action,current_workspace = nil)
		if current_workspace
			(current_workspace.ws_items.to_s.split(',') & @configuration['sa_items']).delete_if{ |e| !user.has_workspace_permission(current_workspace.id, e, action) }
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

	def get_items_list(item_type, workspace=nil)
		if workspace
			if (@configuration['sa_items'] & workspace.ws_items.split(',')).include?(item_type.singularize)
				current_objects = item_type.classify.constantize.get_items_list_for_user_with_permission_in_workspace(@current_user, 'show', workspace, params[:filter_name], params[:filter_way], params[:filter_limit])
			else
				current_objects = []
			end
		else
			if @configuration['sa_items'].include?(item_type.singularize)
				current_objects = item_type.classify.constantize.get_items_list_for_user_with_permission(@current_user, 'show', params[:filter_name], params[:filter_way], params[:filter_limit])
			else
				current_objects = []
			end
		end
		return current_objects
	end

	def admin?
		true
	end

  def groups_of_workspaces_of_item(item)
    groups =[]
    item.workspaces.each {|ws| groups << ws.groups}
    return groups.flatten.uniq.sort! { |a,b| a.title.downcase <=> b.title.downcase }
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

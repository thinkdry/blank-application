require 'rubygems'
require 'RMagick'

class ApplicationController < ActionController::Base

	# Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem
	# Mixin used to specify the controller you want to manage with ExceptionNotification (all the controllers here)
	include ExceptionNotifiable
	# Library used to manage the configuration of the Blank application (and providing 'get_configuration' method)
	include Configuration
	# Library used to get special url helpers for items
	include ActsAsItem::UrlHelpers
	# Library used to get helpers for Captcha
	include YacaphHelper
  # Layout selected with the 'get_da_layout' method
	layout :get_da_layout
	# Used to 'include' and 'require' all the helper modules corresponding to the argument (here all the files present)
  helper :all
	# User to define controller methods as helpers methods too (and so be able to use it inside helpers or views)
	helper_method :available_items_list, :available_languages, :get_sa_config, :right_conf,
		:is_allowed_free_user_creation?, :get_allowed_item_types, :item_types_allowed_to, :get_per_page_value, 
		:admin?, :groups_of_workspaces_of_item, :get_fcke_item_types, :get_items_list
	# Filter checking authentication with 'is_logged' method
  before_filter :is_logged?
	# Filter defining the current locale with the 'set_locale' method
	before_filter :set_locale
	# Filter setting the application configuration with the 'get_configuration' method
	before_filter :get_configuration
	
	# Managing the authentication
  #
  # This function will try to execute the 'logged_in?' method (provided by the AutheticatedSystem library)
	# and so generate the @current_user variable (via the 'current_user' method of that same library).
	# If this function return false (or nil actually), you are redirected to the login page.
	def is_logged?
    redirect_to login_path unless logged_in?
  end

  # Layout for User
  #
  # Get the layout for the application.
  #
  # Checking first the user settings, else taking the default one set inside configuration,
	# or finally take application layout.
	#
	# It will also generate a @search variable if not defined (used inside the search bar).
	def get_da_layout
		@search ||= Search.new
    return current_user.u_layout || @configuration['sa_layout'] || 'application'
	end

  # Allowed Item Types
  #
  # This function will return the available item types depending of the workspace
	# selected. If no workspace, it will return the configuration selection.
  #
  # Parameters :
  # - workspace : Workspace instance (default: nil)
	def get_allowed_item_types(workspace=nil)
		if workspace
			return (workspace.ws_items.to_s.split(',') & @configuration['sa_items'])
		else
			return @configuration['sa_items']
		end
	end

  # Item Types Allowed
	#
	# This function will return the available items types for a user,
	# depending of the action he wants to realize with that item types
	# (new, edit, show, ...) and depending also of the current workspace
	# (if there is one, by default no).
  #
  # Parameters :
  # - user : User instance
  # - action : 'show', 'new', 'edit', 'destroy'
  # - current_workspace : Workspace instance (default: nil)
	def item_types_allowed_to(user, action, current_workspace = nil)
		if current_workspace
			(current_workspace.ws_items.to_s.split(',') & @configuration['sa_items']).delete_if{ |e| !user.has_workspace_permission(current_workspace.id, e, action) }
		else
			available_items_list.delete_if{ |e| Workspace.allowed_user_with_permission(user.id, e+'_'+action).size == 0 }
		end
	end

  # SuperAdministrator
  #
  # This will return true if the current user has system role of superadministrator ('superadmin'),
	# else the user will be redirected with the 'no_permission_redirection' method.
	def is_superadmin?
		no_permission_redirection unless self.current_user && self.current_user.has_system_role('superadmin')
	end

  # Administrator
  #
  # This will return true if the current user has system role of administrator ('admin'),
	# else the user will be redirected with the 'no_permission_redirection' method.
	#
	# (not used actually)
	def is_admin?
		no_permission_redirection unless self.current_user && self.current_user.has_system_role('admin')
	end

  # Default Redirection
  #
  # If the user is inside a workspace, it is redirecting on the workspace show page,
	# else on the root page.
  # A Flash message will be send, defined with the parameter.
	#
	# Parameters :
	# - message : String defining the message to send, default: nil
	def no_permission_redirection(message=nil)
		flash[:error] = message || "Permission denied"
		if current_workspace
			redirect_to workspace_url(current_workspace.id)
		else
			redirect_to '/'
		end
	end

  # List of Items
  #
	# This function will return the items list of the given type for the current user,
	# depending of the workspace. If there is no workspace, it will return
	# the items list of the given type accessible by the current user.
	#
	# Parameters :
	# - item_type : String defining the item type (downcase, singular)
	# - workspace : Workspace instance
	#
  # Usage :
  # <tt>get_item_list('article',current_workspace)</tt>
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

	private

	# Locale definition
	#
	# This function is defining the locale, checking first the params given,
	# after the current user locale preference and finally the default locale set
	# inside the 'blank_init' initializer.
  def set_locale
		I18n.locale = params[:locale] || ((current_user && current_user.u_language) ? current_user.u_language : I18n.default_locale)
  end

	# Image uploading with RMagick
	#
	# This function allows to update image with a treatment done with RMagick library.
	#
	# Parameters :
	# - photo : Path to the image file
	# - crop_width : Integer for the width croping
	# - crop_height : Integer for the height croping
	# - pathname : String defining the path where to save the image
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
#			 self.background_color = 'white'
#			 self.format = 'JPG'
#		 }
     pic.composite!(pic, Magick::CenterGravity, Magick::InCompositeOp)
     File.open(RAILS_ROOT + path_name, "wb") do |f|
			f.write(pic.to_blob)
     end
  end

end

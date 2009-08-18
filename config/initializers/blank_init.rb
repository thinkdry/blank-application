# This initializer is setting all the global variable of the Blank application.

# Loading the Configuration module
include Configuration

# Loading the library Acts_as_item
#p "Loading ActsAsItem model methods"
require "acts_as_item/model.rb"
ActiveRecord::Base.send(:include, ActsAsItem::ModelMethods)
#p 'done'
#p "Loading ActsAsItem controller methods"
require "acts_as_item/controller.rb"
ActionController::Base.send(:include, ActsAsItem::ControllerMethods)
#p 'done'
#require "acts_as_item/helper.rb"
#ApplicationHelper.send(:include, ActsAsItem::HelperMethods)

# Defining the global variable
ITEMS = ['article', 'image', 'cms_file', 'video', 'audio', 'feed_source', 'bookmark','newsletter']
# Variable defining the languages available for the application
LANGUAGES = ['en-US', 'fr-FR']
# Variable defining the workspace types available for the application
WS_TYPES = ['closed', 'public', 'authorized', 'archived']
# Variable defining the right types for the application
RIGHT_TYPES = ['system', 'workspace']
# Variable defining the different state for the comments for the application
COMMENT_STATE = ['posted', 'validated', 'rejected']
# Variable defining the default comment status for the application
DEFAULT_COMMENT_STATE = 'validated'
# Variable defining the available layout for the application
LAYOUTS_AVAILABLE = ['application', 'app_fat_menu']
# # Variable defining the filtering attributes available for the application
SEARCH_FILTERS = ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title']
# 
IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"]
# Set the default Captcha images number
CAPTCHA_IMAGES_NUMBER = 10


# Setting the locales files and the default language
I18n.default_locale = "en-US"
#I18n.locale = 'fr-FR'
#I18n.default_locale = 'fr-FR'
#%w{yml rb}.each do |type|
#  I18n.load_path += Dir.glob("#{RAILS_ROOT}/app/locales/*.#{type}")
#end
LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"
#LOCALES_AVAILABLE = Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
#  File.basename(File.basename(locale_file, ".rb"), ".yml")
#end.uniq.sort
LANGUAGES.each do |l|
	I18n.load_path << "#{LOCALES_DIRECTORY}/#{l}.yml"
end

# Variable used by ExceptionNotifier plugin
APPLICATION_ADMINS = ['paco@thinkdry.com', 'anup.nivargi@thinkdry.com',	'nagarjuna@thinkdry.com', 'sylvain@thinkdry.com']
APPLICATION_NAME = get_sa_config['sa_application_name']
ExceptionNotifier.exception_recipients = APPLICATION_ADMINS
ExceptionNotifier.sender_address = 'admin@thinkdry.com'
ExceptionNotifier.email_prefix = APPLICATION_NAME
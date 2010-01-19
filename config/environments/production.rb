# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# See everything in the log (default is :info)
# config.log_level = :debug

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Enable threaded mode
# config.threadsafe!

# Defining the project name
PROJECT_NAME = 'blank'.freeze
# Containers Available to current setup
CONTAINERS = ['workspace','website','folder'].sort.freeze
# Items available to the current setup
ITEMS = ['article', 'image', 'cms_file', 'video', 'audio', 'feed_source', 'bookmark','newsletter', 'group', 'page'].sort.freeze
# Variable defining the languages available for the application
LANGUAGES = ['en-US', 'fr-FR'].freeze
# Variable defining the workspace types available for the application
WS_TYPES = ['closed', 'public', 'authorized', 'archived'].freeze
# Variable defining the right types for the application
RIGHT_TYPES = ['system', 'container'].freeze
# Variable defining the different state for the comments for the application
COMMENT_STATE = ['posted', 'validated', 'rejected'].freeze
# Variable defining the default comment status for the application
DEFAULT_COMMENT_STATE = 'validated'
# Variable defining the available layout for the application
LAYOUTS_AVAILABLE = ['application', 'app_fat_menu'].freeze
# # Variable defining the filtering attributes available for the application
SEARCH_FILTERS = ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'].freeze
#
IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"].freeze
# Set the default Captcha images number
CAPTCHA_IMAGES_NUMBER = 10
# Variable to define number of newsletters to send per hour
NEWSLETTERS_PER_HOUR = 20

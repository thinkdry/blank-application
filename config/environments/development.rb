# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.

# This changement is BAD. Should be set at FALSE but generate an error on plugin reload
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

# Defining constants
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
# Variable defining the filtering attributes available for the application
SEARCH_FILTERS = ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'].freeze
# Variables defining the image types allowed
IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"].freeze
# Set the default Captcha images number
CAPTCHA_IMAGES_NUMBER = 10
# Variable to define number of newsletters to send per hour
NEWSLETTERS_PER_HOUR = 20

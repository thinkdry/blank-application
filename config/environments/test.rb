# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

# Defining constants
# Containers Available to current setup
CONTAINERS = ['workspace']
# Items available to the current setup
ITEMS = ['article', 'image', 'cms_file', 'video', 'audio', 'feed_source', 'bookmark','newsletter', 'group']
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
# Variable to define number of newsletters to send per hour
NEWSLETTERS_PER_HOUR = 20
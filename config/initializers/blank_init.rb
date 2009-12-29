# This initializer is setting all the global variable of the Blank application.

# Loading the Configuration module
include Configuration

#ActiveRecord::Base.send(:include, CustomModelValidations)
include CustomModelValidations

# INCLUDING LIBRAIRIES IN DA GOOD PLACE
# for authorization
load 'authorized.rb'
load 'authorizable.rb'
ActiveRecord::Base.send                   :include, Authorized::ModelMethods
ActionController::Base.send               :include, Authorizable::ControllerMethods
ActiveRecord::Base.send                   :include, Authorizable::ModelMethods
# for research
load 'searchable.rb'
ActiveRecord::Base.send                   :include, Searchable::ModelMethods
#ActionController::Base.send               :include, Authorizable::ControllerMethods


# Setting the locales files and the default language
if !get_sa_config['sa_default_language'].to_s.blank?
  I18n.default_locale = "#{get_sa_config['sa_default_language']}"
else
  I18n.default_locale = "en-US"
end
#I18n.locale = 'fr-FR'
#I18n.default_locale = 'fr-FR'
#%w{yml rb}.each do |type|
#  I18n.load_path += Dir.glob("#{RAILS_ROOT}/app/locales/*.#{type}")
#end
LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"
#LOCALES_AVAILABLE = Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
#  File.basename(File.basename(locale_file, ".rb"), ".yml")
#end.uniq.sort
#LANGUAGES.each do |l|
#	I18n.load_path << "#{LOCALES_DIRECTORY}/#{l}.yml"
#end
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '*.yml')]
# Variable used by ExceptionNotifier plugin
if get_sa_config['sa_exception_notifier_activated'] == 'true'
  APPLICATION_ADMINS = get_sa_config['sa_exception_followers_email']
  APPLICATION_NAME = get_sa_config['sa_application_name']
  ExceptionNotifier.exception_recipients = APPLICATION_ADMINS
  ExceptionNotifier.sender_address = 'admin@thinkdry.com'
  ExceptionNotifier.email_prefix = APPLICATION_NAME
end

# Load action_mailer settings if they are already set
if File.exist?("#{RAILS_ROOT}/config/customs/action_mailer.yml")
  @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
  ActionMailer::Base.smtp_settings = {
    :address => @mailer_config['sa_mailer_address'],
    :domain => @mailer_config['sa_mailer_domain'],
    :port => @mailer_config['sa_mailer_port'],
    :user_name => @mailer_config['sa_mailer_user_name'],
    :password => @mailer_config['sa_mailer_password'],
    :authentication => (@mailer_config['sa_mailer_authentication'] && !@mailer_config['sa_mailer_authentication'].blank?) ? @mailer_config['sa_mailer_authentication'].to_sym : nil
  }
end
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.template_root = "#{RAILS_ROOT}/app/views/admin"


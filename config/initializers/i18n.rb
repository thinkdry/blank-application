#I18n.locale = 'nl-NL'
#I18n.load_path << "#{RAILS_ROOT}/config/translations.yml"


I18n.default_locale = "fr-FR"
#I18n.locale = 'fr-FR'
#I18n.default_locale = 'fr-FR'
#%w{yml rb}.each do |type|
#  I18n.load_path += Dir.glob("#{RAILS_ROOT}/app/locales/*.#{type}")
#end
LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"
#LOCALES_AVAILABLE = Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
#  File.basename(File.basename(locale_file, ".rb"), ".yml")
#end.uniq.sort
#I18n.load_path += Dir.glob("#{LOCALES_DIRECTORY}/config/locales/*.yml")
#I18n.load_path << "#{LOCALES_DIRECTORY}/fr-FR.yml"
I18n.load_path << "#{LOCALES_DIRECTORY}/en-US.yml"
I18n.load_path << "#{LOCALES_DIRECTORY}/fr-FR.yml"
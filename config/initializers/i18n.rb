#I18n.locale = 'nl-NL'
#I18n.load_path << "#{RAILS_ROOT}/config/translations.yml"

%w{yml rb}.each do |type|
  I18n.load_path += Dir.glob("#{RAILS_ROOT}/app/locales/**/*.#{type}")
end
I18n.default_locale = 'LOL'
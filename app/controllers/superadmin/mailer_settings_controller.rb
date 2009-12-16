class Superadmin::MailerSettingsController < Admin::ApplicationController
  
  before_filter :is_superadmin?

  def index
    if File.exist?("#{RAILS_ROOT}/config/customs/action_mailer.yml")
      @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
      @mailer_config.extend Extentions::HashFeatures
    else
      @mailer_config_hash = { "sa_mailer_authentication"=>"",
                              "sa_mailer_port"=>"",
                              "sa_mailer_user_name"=>"",
                              "sa_mailer_password"=>"",
                              "sa_mailer_address"=>"",
                              "sa_mailer_domain"=>""}
      @mailer_config = File.new("#{RAILS_ROOT}/config/customs/action_mailer.yml", "w+")
      @mailer_config.syswrite(@mailer_config_hash.to_yaml)
      @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
      @mailer_config.extend Extentions::HashFeatures
    end
    
  end

  def updating
    @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
    @mailer_config.extend Extentions::HashFeatures
    res = @mailer_config.merge!(params[:mailer_config])
    @new=File.new("#{RAILS_ROOT}/config/customs/action_mailer.yml", "w+")
    @new.syswrite(res.to_yaml)
    @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
    ActionMailer::Base.smtp_settings = {
      :address => @mailer_config['sa_mailer_address'],
      :domain => @mailer_config['sa_mailer_domain'],
      :port => @mailer_config['sa_mailer_port'],
      :user_name => @mailer_config['sa_mailer_user_name'],
      :password => @mailer_config['sa_mailer_password'],
      :authentication => @mailer_config['sa_mailer_authentication'].to_sym
    }
		flash[:notice] = "Action Mailer Settings Updated"
    redirect_to editing_superadmin_action_mailer_settings_path
  end


end
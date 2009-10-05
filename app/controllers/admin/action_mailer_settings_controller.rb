class Admin::ActionMailerSettingsController < ApplicationController
  before_filter :is_superadmin?

  def editing
    @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
    @mailer_config.extend Extentions::HashFeatures
  end

  def updating
    @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
    @mailer_config.extend Extentions::HashFeatures
    res = @mailer_config.merge!(params[:hash])
    @new=File.new("#{RAILS_ROOT}/config/customs/action_mailer.yml", "w+")
    @new.syswrite(res.to_yaml)
		flash[:notice] = "Action Mailer Settings Updated"
    redirect_to editing_admin_action_mailer_settings_path
  end


end
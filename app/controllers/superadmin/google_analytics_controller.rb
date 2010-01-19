class Superadmin::GoogleAnalyticsController < Admin::ApplicationController

  before_filter :is_superadmin?

  def index
    if File.exist?("#{RAILS_ROOT}/config/customs/google_analytics.yml")
      @analytic_config = YAML.load_file("#{RAILS_ROOT}/config/customs/google_analytics.yml")
      @analytic_config.extend Extentions::HashFeatures
    else
      @google_analytic_hash = {"sa_analytic_login" => "", "sa_analytic_password" => "" }
      @analytic_config = File.new("#{RAILS_ROOT}/config/customs/google_analytics.yml", "w+")
      @analytic_config.syswrite(@google_analytic_hash.to_yaml)
      @analytic_config = YAML.load_file("#{RAILS_ROOT}/config/customs/google_analytics.yml")
      @analytic_config.extend Extentions::HashFeatures
    end
  end

  def updating
    @analytic_config = YAML.load_file("#{RAILS_ROOT}/config/customs/google_analytics.yml")
    @analytic_config.extend Extentions::HashFeatures
    res = @analytic_config.merge!(params[:analytic_config])
    @new = File.new("#{RAILS_ROOT}/config/customs/google_analytics.yml", "w+")
    @new.syswrite(res.to_yaml)
		flash[:notice] = "Google Analytics Settings Updated"
    redirect_to superadmin_google_analytics_path
  end




end



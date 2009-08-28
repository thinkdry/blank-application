class Admin::GeneralSettingsController < ApplicationController

	before_filter :is_superadmin?

	def editing
		@configuration.extend Extentions::HashFeatures
	end
	
	def updating
		res = @configuration.merge!(params[:configuration])
		#raise params[:configuration].inspect
    #File.rename("#{RAILS_ROOT}/config/customs/sa_config.yml", "#{RAILS_ROOT}/config/customs/old_sa_config.yml")
    @new=File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
    @new.syswrite(res.to_yaml)
		flash[:notice] = "General settings updated"
    redirect_to editing_admin_general_settings_path
	end


end

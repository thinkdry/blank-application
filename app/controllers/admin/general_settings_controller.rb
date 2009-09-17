class Admin::GeneralSettingsController < ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	# Action managing the form presenting the general settings of the application
	#
	# Usage URL :
	# - GET  /admin/general_settings/editing
	def editing
		@configuration.extend Extentions::HashFeatures
	end

	# Action updating the YAML config file with the params set in the previous form
	#
	# Usage URL :
	# - PUT /admin/general_settings/updating
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

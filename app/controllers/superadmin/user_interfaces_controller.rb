class Superadmin::UserInterfacesController < Admin::ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	# Action managing the form presenting the user interface settings of the application
	#
	# Usage URL :
	# - GET  /admin/user_interface/editing
	def index
		@elements = Element.current
    @temp = Element.templates
		@configuration.extend Extentions::HashFeatures
	end

	# Action updating the YAML config file with the params set in the previous form
	#
	# Usage URL :
	# - PUT /admin/user_interfaces/updating
	def updating
    if !params[:configuration][:sa_logo_url].blank? && (IMAGE_TYPES.include?(params[:configuration][:sa_logo_url].content_type.chomp))
      upload_photo(params[:configuration][:sa_logo_url], 255, 40, '/public/config_files/logo.jpg')
    end
    if !params[:configuration][:sa_favicon_url].blank? && (IMAGE_TYPES.include?(params[:configuration][:sa_favicon_url].content_type.chomp))
      upload_photo(params[:configuration][:sa_favicon_url],16,16, '/public/config_files/favicon.ico')
    end
    params[:configuration][:sa_favicon_url] = "/config_files/favicon.ico"
    params[:configuration][:sa_logo_url] = "/config_files/logo.jpg"
		res = @configuration.merge!(params[:configuration])
	  @new=File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
		@new.syswrite(res.to_yaml)
		flash[:notice] = "General settings updated"

    #		if !params[:newtemplate].blank?
    #      params[:template].each do |k_elmt, v_elmt|
    #				@element = Element.create(:name => k_elmt.to_s, :bgcolor => v_elmt.to_s,:template => params[:newtemplate])
    #      end
    #      flash[:notice]="New Template Created"
    #    elsif params[:template]
    #      params[:template].each do |k_elmt, v_elmt|
    #				Element.find(:first, :conditions => {:name => k_elmt.to_s, :template => "current"}).update_attributes(:bgcolor => v_elmt.to_s)
    #      end
    #      flash[:notice]="Saved Sucessfully"
    #    else
    #      flash[:notice]="Changes not Saved"
    #    end

		redirect_to superadmin_user_interfaces_path

	end

	# Action setting the color checked (used with AJAX call)
	#
  # Usage URL
  # - GET /user_interfaces/check_color
	def check_color
		@elements = Element.template_elements(params[:temp])
    @temp = Element.templates
		render :partial => 'color_checked'
	end

end

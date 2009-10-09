# Configuration for Blank Application
# 
# Blank Application is configured through the SuperAdministration module accessible to the 'superadmin' user
# 
# Major Application Configurations can be set up using this module.
# 
# The settings are stored in a YAML file.
#
# Initially the /config/customs/default_config.yml file is loaded(default settings).
#
# After the Superadministrator has setup the Superadministration Module the configurations will be stored in the /config/customs/sa_config.yml file
#
# The setttings are accessed through the following methods in the Application
#
module Configuration

  # Free User Creation
  #
  # Check setting to verify if User can register directly with the application
	def is_allowed_free_user_creation?
		return @configuration['sa_allowed_free_user_creation']=='true'
	end

  # Check if Automatic Private Workspace Creation is Allowed
	def is_given_private_workspace
		return @configuration['sa_automatic_private_workspace']=='true'
	end

  # Check if Email Activation for User is Mandatory
	def is_mandatory_user_activation?
		return @configuration['sa_mandatory_user_activation']=='true'
	end

  # Get Selected Items List
  # 
  # will return a array of string of available items
	def available_items_list
		return @configuration['sa_items']
	end

  # Get Available Languages
  #
  # will return a array of string of available languages if not empty array
	def available_languages
    return (@configuration['sa_languages'].nil? || @configuration['sa_languages'].empty?) ? [] : @configuration['sa_languages']
	end

  # Load the SuperAdmin Configuration
	def get_sa_config
		if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
			return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
		else
			return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
		end
	end

	def get_configuration
		@configuration ||= get_sa_config
	end

  #will return a array of string of available layouts if not empty array
  def available_layouts
		return (@configuration['sa_layouts'].nil? || @configuration['sa_layouts'].empty?) ? [] : @configuration['sa_llayouts']
	end

  # Set PerPage Values for Pagination(default 10)
	def get_per_page_value
    if current_user.u_per_page
      current_user.u_per_page
		elsif (res=@configuration['sa_per_page_default']).to_i > 0
			return res
		else
			return 10
		end
	end

	# Get the Item types available for FCKE
	def get_fcke_item_types
		return ['page', 'image', 'cms_file', 'video', 'audio', 'bookmark']
	end
  
end
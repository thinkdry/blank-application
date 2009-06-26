# Configuration for Blank Application Accessed Through SuperAdministration Module
module Configuration

  # Check if Free User Creation is Allowed
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
	def available_items_list
		return @configuration['sa_items']
	end

  # Get Available Languages
	def available_languages
		return @configuration['sa_languages']
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
  
end
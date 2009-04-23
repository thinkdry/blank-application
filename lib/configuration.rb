module Configuration

	def is_allowed_free_user_creation?
		return @configuration['sa_allowed_free_user_creation']=='true'
	end

	def is_given_private_workspace
		return @configuration['sa_automatic_private_workspace']=='true'
	end

	def is_mandatory_user_activation?
		return @configuration['sa_mandatory_user_activation']=='true'
	end

	def available_items_list
		return @configuration['sa_items']
	end

	def available_languages
		return @configuration['sa_languages']
	end

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

	def get_per_page_value
		if (res=@configuration['sa_per_page_default']).to_i > 0
			return res
		else
			return 10
		end
	end
  
end
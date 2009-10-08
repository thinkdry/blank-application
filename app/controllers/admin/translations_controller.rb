class Admin::TranslationsController < ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	# Action managing the form presenting the translations of the application
	#
	# Usage URL :
	# - GET  /admin/translations/editing
	def editing
		@file = YAML.load_file("#{RAILS_ROOT}/config/locales/#{I18n.default_locale}.yml")
    @res = @file[I18n.default_locale.to_s]
    @language = I18n.default_locale.to_s
		translation_options
	end

	# Action updating the YAML locale file with the values set in the previous form
	#
	# Usage URL :
	# - PUT /admin/translations/updating
	def updating
		@yaml = YAML.load_file("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml")
   	(['general', 'layout', 'user', 'workspace', 'item']+ITEMS+['superadministration', 'others']).each do |section|
			p "============================= "+section
			p "============================= "+(!params[section].nil? && !@yaml[params[:language]][section].nil?).inspect
			if !params[section].nil? && !@yaml[params[:language]][section].nil?
				params[section].each do |subsection, list|
					if @yaml[params[:language]][section][subsection]
						list.each do |key, value|
							if @yaml[params[:language]][section][subsection][key]
								@yaml[params[:language]][section][subsection][key] = value.to_s
							else
								#flash[:error] = "Unknown key"
							end
						end
					else
						#flash[:error] = "Unknown subsection"
					end
				end
			else
				#flash[:error] = "Unknown section"
			end
		end
		#raise @yaml['en-US']['general'].inspect
    File.rename("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml", "#{RAILS_ROOT}/config/locales/old_#{params[:language]}.yml")
    @new=File.new("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml", "w+")
    if @new.syswrite(@yaml.to_yaml)
      flash[:notice] = "Updated Sucessfully"
    else
      flash[:notice] = "Update Failed"
		end
		redirect_to editing_admin_translations_path
	end

	# Action allowing to switch the language (used with AJAX call)
  #
  # Usage URL :
  # - GET /translations/language_switching
	def language_switching
		if params[:locale_to_conf] == 'translation_addition'
			translation_options
			render :partial => 'translation_addition'
		else
			yaml = YAML.load_file("#{RAILS_ROOT}/config/locales/#{params[:locale_to_conf]}.yml")
			@res = yaml[params[:locale_to_conf].to_s]
			@language = params[:locale_to_conf].to_s
		  translation_options
			render :partial => 'translations_tab'
		end
  end

  # Action allowing to save a new translation key for each locale file
  #
  # Usage URL :
  # - POST /translations/translations_new
	def translations_new
		if params[:res][:section] && params[:res][:subsection] && params[:res][:key]
			LANGUAGES.each do |l|
				@yaml = YAML.load_file("#{RAILS_ROOT}/config/locales/#{l}.yml")
				if @yaml[l][params[:res][:section]][params[:res][:subsection]]
					tmp = { params[:res][:key] => params[:translations][l] }
					@yaml[l][params[:res][:section]][params[:res][:subsection]].merge!(tmp)
				else
					tmp = { params[:res][:subsection] => { params[:res][:key] => params[:translations][l] } }
					@yaml[l][params[:res][:section]].merge!(tmp)
				end
				@new=File.new("#{RAILS_ROOT}/config/locales/#{l}.yml", "w+")
				@new.syswrite(@yaml.to_yaml)
			end
		end
		redirect_to '/superadministration/translations'
	end

	private
	# Method setting the different categories inside the YAML file
	# TODO check directly the YAML structure, (and so put in an other file the localization ?)
  def translation_options
		@translation_sections = [['general', 'layout', 'user', 'workspace', 'item', 'group', 'people', 'comment',  'home', 'website_contact', 'workspace_contact', 'rating', 'mailer']+ITEMS].flatten.sort
  end


end

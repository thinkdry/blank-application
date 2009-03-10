class SuperadministrationController < ApplicationController

	before_filter :is_superadmin?

	def superadministration
			if params[:part] == "default"
			elsif params[:part] == "general"
				@conf = get_sa_config
				@logo = Picture.find_by_name('logo')
			elsif params[:part] == "css"
				@elements = Element.find(:all, :conditions => {:template=>"current"})
				@temp=Element.find( :all, :select => 'DISTINCT template' )
			elsif params[:part] == "translations"
				@file = YAML.load_file("#{RAILS_ROOT}/config/locales/#{I18n.default_locale}.yml")
				@res = @file[I18n.default_locale.to_s]
				@language = I18n.default_locale.to_s
        translation_options
			elsif params[:part] == "roles"
        @roles = Role.all
				@workspace_roles = Role.find(:all, :conditions => {:type_role => "workspace"})
        @system_roles = Role.find(:all, :conditions => {:type_role => "system"})
			else
				flash[:notice] = "Unexisting section"
				redirect_to '/'
			end
			if request.post?
				render :partial => params[:part], :layout => false
			end
	end
	
	def general_changing
		list = ['items', 'languages', 'feed_items_importation_types', 'ws_types']
		@conf = get_sa_config
		if params[:picture]
				upload_photo(params[:picture][:picture],240,55,@conf['sa_logo_path']) if !params[:picture][:picture].blank? and (@@image_types.include?params[:picture][:picture].content_type.chomp)
        upload_photo(params[:picture][:favicon],16,16,@conf['sa_favicon_path']) if !params[:picture][:favicon].blank? and (@@image_types.include?params[:picture][:favicon].content_type.chomp)
			@conf['sa_application_name'] = params[:conf][:sa_application_name]
			@conf['sa_application_url'] = params[:conf][:sa_application_url]
			@conf['sa_contact_email'] = params[:conf][:sa_contact_email]
			list.each do |l|
				@conf['sa_'+l] = check_to_tab(l)
			end
			# Update the default ws_config (with the id 1 normaly ...)
			@default_conf = WsConfig.find(1)
			@default_conf.update_attributes(:ws_items => check_to_tab('items').join(','), :ws_feed_items_importation_types => check_to_tab('feed_items_importation_types').join(','))

			#File.rename("#{RAILS_ROOT}/config/customs/sa_config.yml", "#{RAILS_ROOT}/config/customs/old_sa_config.yml")
			
			@new=File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
			@new.syswrite(@conf.to_yaml)
			redirect_to '/superadministration/general'
			flash[:notice] = "General settings updated"
		else
			redirect_to '/'
			flash[:notice] = "Vous n'avez pas ce droit."
		end
	end

	def check_color
		@elements = Element.find(:all, :conditions => {:template => params[:temp]})
    @temp = Element.find(:all, :select => 'DISTINCT template')
		render :partial => 'color_checked'
	end

  def colors_changing
    if !params[:newtemplate].blank?
      params[:template].each do |k_elmt, v_elmt|
				@element = Element.create(:name => k_elmt.to_s, :bgcolor => v_elmt.to_s,:template => params[:newtemplate])
      end
      flash[:notice]="New Template Created"
			redirect_to '/superadministration/css'
    elsif params[:template]
      params[:template].each do |k_elmt, v_elmt|
				Element.find(:first, :conditions => {:name => k_elmt.to_s, :template => "current"}).update_attributes(:bgcolor => v_elmt.to_s)
      end
      flash[:notice]="Saved Sucessfully"
      redirect_to '/superadministration/css'
    else
      flash[:notice]="Changes not Saved"
      redirect_to '/superadministration/css'
    end
  end
   	
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

	def translations_changing
    @yaml = YAML.load_file("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml")
   	['general', 'layout', 'user', 'workspace', 'item']+ITEMS+['superadministration', 'others'].each do |section|
			if params[section.to_sym] && @yaml[params[:language]][section]
				params[section.to_sym].each do |subsection, list|
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
    File.rename("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml", "#{RAILS_ROOT}/config/locales/old_#{params[:language]}.yml")
    @new=File.new("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml", "w+")
     if @new.syswrite(@yaml.to_yaml)
       flash[:notice] = "Updated Sucessfully"
      redirect_to '/superadministration/translations'
    else
      flash[:notice] = "Update Failed"
     redirect_to '/superadministration/translations'
    end
  end

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
  def translation_options
		@translation_sections = ['general', 'layout', 'user', 'workspace', 'item']+ITEMS+['superadministration', 'others']
  end
	
end

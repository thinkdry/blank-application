class SuperadministrationController < ApplicationController

	def superadministration
		if current_user.is_superadmin?
			if params[:part] == "default"
			elsif params[:part] == "general"
				if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
					@conf = YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
				else
					@conf = YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
				end
				@logo = Picture.find_by_name('logo')
			elsif params[:part] == "css"
				@elements = Element.find(:all, :conditions => {:template=>"current"})
				@temp=Element.find( :all, :select => 'DISTINCT template' )
			elsif params[:part] == "translations"
				@file = YAML.load_file("#{RAILS_ROOT}/config/locales/#{I18n.default_locale}.yml")
				@res = @file[I18n.default_locale.to_s]
				@language = I18n.default_locale.to_s
			elsif params[:part] == "roles"
				@roles
				@permissions
			else
				flash[:notice] = "Unexisting section"
				redirect_to '/'
			end
			if request.post?
				render :partial => params[:part], :layout => false
			end
		else
			flash[:notice] = "Vous n'avez pas ce droit."
			redirect_to ''
		end
	end

	def check_to_tab(param)
		@list = params[param.to_sym]
		res = []
		if @list
				@list.each do |k, v|
					res << k.to_s
				end
		end
		return res
	end
	
	def general_changing
		if current_user.is_superadmin?
			list = ['items', 'languages', 'feed_items_importation_types', 'ws_types']
			if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
				@conf = YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
			else
				@conf = YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
			end
			if params[:picture]
				@picture = Picture.new(params[:picture])
				@picture.name = 'logo'
				if Picture.find_by_name('logo')
					Picture.find_by_name('logo').update_attributes(:name => 'old_logo')
				end
				@picture.save
			end
      
			list.each do |l|
				@conf['sa_'+l] = check_to_tab(l)
			end

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
    #if @element.update_attributes(params[:element])
      #  flash[:notice]="Saved Sucessfully"

      #else
        # flash[:notice]="Changes not Saved"
         #render :action => "/"
      #end
   #end
   	
	def language_switching
		@yaml = YAML.load_file("#{RAILS_ROOT}/config/locales/#{params[:locale_to_conf]}.yml")
		@res = @yaml[params[:locale_to_conf].to_s]
		@language = params[:locale_to_conf].to_s
    
		if @yaml
			render :partial => 'translations_tab'
		else
			render :text => "Impossible d'ouvrir le fichier de langue demandé."
		end
  end

	def translations_changing

    @yaml = YAML.load_file("#{RAILS_ROOT}/config/locales/#{params[:language]}.yml")
   	["general","layout", "user", "login","profil","home","workspace","article","item","file","audio","video","publication","bookmark","picture"].each do |type|
			if params[type.to_sym] && @yaml[params[:language].to_s][type] 
				params[type.to_sym].each do |k, v|
					if @yaml[params[:language]][type][k]
            @yaml[params[:language]][type][k] = v.to_s
          end
       end
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
end

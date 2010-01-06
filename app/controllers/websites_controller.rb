class WebsitesController < ApplicationController

  #layout 'websites/application'

  def index
    p ">>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<"
    p params
    p ">>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<"
    if params[:title_sanitized].nil? && logged_in? && params[:site_url].nil?
				redirect_to admin_root_url
		elsif get_website && Page.exists?(:id => @current_website.home_page_id) && @current_website.website_state == 'published'
		  # Selected Language
			if params[:sl]
				session[:sl] = params[:sl]
			else
				session[:sl] ||= 'fr'
			end
        if !params[:title_sanitized].blank? && @current_website.pages.exists?(:title_sanitized => params[:title_sanitized])
          @page = @current_website.pages.find(:first, :conditions => {:title_sanitized => params[:title_sanitized]})
					session[:fck_item_id] = @page.id
          session[:fck_item_type] = @page.class.to_s
					# Specific for gallery page
					if @page.page_type.split('_').first == 'gallery'
						@pictures = @current_website.images
						@partial_to_render = 'websites/gallery'
					# Specific for contact page
					elsif @page.page_type.split('_').first == 'contact'
						@person = session[:person] || Person.new
						@email_values = session[:email] || {}
						session[:person] = nil
						session[:email] = nil
						@partial_to_render = 'websites/contact'
					# Specific for guestbook
					elsif  @page.page_type.split('_').first == 'guestbook'
						@person = session[:person] || Person.new
						@email_values = session[:email] || {}
						session[:person] = nil
						session[:email] = nil
						@guestbook_messages = DataPerson.find(:all, :conditions => {:workspace_id => @current_website.workspace.id, :state => 'validated', :origin => 'guestbook_form'}, :order => 'created_at DESC')
            @partial_to_render = 'websites/guestbook'
					end
					# Finally render the partial with @page, @current_website
          render :partial => 'page', :layout => 'websites/application'
          
        # Manage other type of Pages
        elsif (params[:title_sanitized] == "sitemap")
          if @current_website.sitemap
            render :xml => File.open(@current_website.sitemap.path){ |f| f.read}, :layout => false
          else
            render :xml => '', :layout => false
          end
         # Specific for intro page
        elsif @current_website.intro_page_id || (params[:title_sanitized] == "intro")
          @page = Page.find(@current_website.intro_page_id)
          #session[:intro_page_viewed] ||= true
					session[:fck_item_id] = @page.id
          session[:fck_item_type] = @page.class.to_s
          render :partial => 'intro', :layout => false
				else
          # Even if the page is not valid
          @page = Page.find(@current_website.home_page_id)
					session[:fck_item_id] = @page.id
          session[:fck_item_type] = @page.class.to_s
          render :partial => 'page', :layout => 'websites/application'
        end
    elsif get_website
       render :template => "#{RAILS_ROOT}/public/#{@current_website.website_state}.html", :layout => false
    else
      redirect_to admin_root_url
    end
  end
  
  def form_management
		website = Website.find(params[:website_id])
    workspace = website.workspace
    user_id = (!website.user_for_contacts.nil? && website.user_for_contacts != 0) ? website.user_for_contacts : workspace.users.first.id
    if yacaph_validated?
			if !(@person = Person.find(:first, :conditions => {:email => params[:person][:email], :user_id => user_id}))
				@person = Person.new(params[:person].merge!({'user_id' => user_id}))
				@person.save
			else
				params[:person].delete('primary_phone') if params[:person][:primary_phone].blank?
				@person.update_attributes(params[:person])
			end
			if @contact_workspace = ContactsWorkspace.find(:first, :conditions => {:workspace_id => workspace.id, :contactable_id => @person.id, :contactable_type => 'Person'})
				@contact_workspace.update_attributes(:state =>'subscribed') if params[:state]
			elsif @person.id
				ContactsWorkspace.create(:contactable_id => @person.id, :contactable_type => "Person", :workspace_id => workspace.id, :state => params[:state] ? 'subscribed' : 'not_subscribed')
			end
			if @person.id && DataPerson.new(:person_id => @person.id, :workspace_id => workspace.id, :origin => params[:person][:origin], :type_data => '', :data => params[:email]).save
				UserMailer.deliver_contact_notification(website, params[:person].merge!(params[:email])) rescue p "email not delivered"
				flash[:notice] = "Votre demande a bien été envoyée."
			else
				flash[:error] = "Votre demande a pu être enregsitrée mais pas envoyée."
				session[:person] = @person
				session[:email] = params[:email]
			end
		else
			session[:person] = Person.new(params[:person])
			session[:email] = params[:email]
			flash[:error] = "Le code de vérification est érroné."
		end
#    redirect_to '/'+Page.find(website.home_page_id).title_sanitized
    redirect_to '/'+params[:title_sanitized]
  end
  
  
  protected
  
  def get_website
		site_url = params[:site_url] || request.url.split('//').second.split('/').first
		#wsu = WebsiteUrl.find_by_sql("SELECT website_urls.website_id FROM website_urls WHERE website_urls.name = '#{ws_url}' LIMIT 1").first
		if @current_website = WebsiteUrl.find(:first, :conditions => {:name => site_url}).try('website')
			session[:website_id] = @current_website.id
			return true
		else
			return false
		end
	end
end

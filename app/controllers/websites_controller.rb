class WebsitesController < ApplicationController

  #layout 'websites/application'

  def index
    if params[:title_sanitized].nil? && logged_in? && params[:site_url].nil?
				redirect_to admin_root_url
    elsif get_website && (Page.exists?(:id => @current_website.home_page_id, :published => true) || @current_website.pages.exists?(:page_type => 'home', :published => true)) && @current_website.website_state == 'published'
		  # Selected Language
			if params[:sl]
				session[:sl] = params[:sl]
			else
				session[:sl] ||= 'fr'
			end
      if !params[:title_sanitized].blank? && @current_website.pages.exists?(:title_sanitized => params[:title_sanitized], :published => true)
        @page = @current_website.pages.find(:first, :conditions => {:title_sanitized => params[:title_sanitized], :published => true})
				session[:fck_item_id] = @page.id
        session[:fck_item_type] = @page.class.to_s
					# Specific for gallery page
				if @page.page_type == 'gallery'
				  @pictures = @current_website.images.published
					@partial_to_render = 'websites/gallery'
					# Specific for contact page
					# TODO What to do? waiting for Contact Management
				elsif @page.page_type == 'contact'
					@person = session[:person] || Person.new
					@email_values = session[:email] || {}
					session[:person] = nil
					session[:email] = nil
					@partial_to_render = 'websites/contact'
					# Specific for guestbook
					# TODO What to do? waiting for Contact Management
				elsif  @page.page_type == 'guestbook'
					@person = session[:person] || Person.new
					@email_values = session[:email] || {}
					session[:person] = nil
					session[:email] = nil
					@guestbook_messages = DataPerson.find(:all, :conditions => {:workspace_id => @current_website.creator.private_workspace.id, :state => 'validated', :origin => 'guestbook_form'}, :order => 'created_at DESC')
          @partial_to_render = 'websites/guestbook'
				end
					# Finally render the partial with @page, @current_website
        render :partial => 'page', :layout => 'websites/application'
          
        # Manage other type of Pages
      elsif (params[:title_sanitized] == "sitemap")
        if @current_website.sitemap_file_name
          render :xml => File.open(@current_website.sitemap.path){ |f| f.read}, :layout => false
        else
          render :xml => '', :layout => false
        end
         # Specific for intro page
      elsif @current_website.pages.exists?(:page_type => 'intro', :published => true)
        @page = @current_website.pages.find(:first, :page_type => 'intro', :published => true)
        #session[:intro_page_viewed] ||= true
			  session[:fck_item_id] = @page.id
        session[:fck_item_type] = @page.class.to_s
        render :partial => 'intro', :layout => false
		  else
        # Even if the page is not valid
        @page = @current_website.pages.find(:first, :conditions => {:page_type => 'home', :published => true})
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
  
  def update
    @page = Page.find(params[:id])
    # TODO check if it is saving!
    @page.update_attribute(:body, params[:content])
    render :nothing => true
  end
  
  
  protected
  
  def get_website
		site_url = params[:site_url] || request.url.split('//').second.split('/').first
		#wsu = WebsiteUrl.find_by_sql("SELECT website_urls.website_id FROM website_urls WHERE website_urls.name = '#{ws_url}' LIMIT 1").first
		if params[:site_title] && Website.exists?(:title => params[:site_title])
      @current_website = Website.find_by_title(params[:site_title])
      session[:website_id] = @current_website.id
      return true
    elsif @current_website = WebsiteUrl.find(:first, :conditions => {:name => site_url}).try('website')
			session[:website_id] = @current_website.id
			return true
		else
			return false
		end
	end
end

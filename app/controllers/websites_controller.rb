class WebsitesController < ApplicationController

  #layout 'websites/application'

  def index
    # Check website url exists & get website object
    if current_website && @current_website.published?
      # Get the first page of the website tree if there is no title_sinatized
      if params[:title_sanitized].nil? && (@current_website.menus.first.try('page') || @current_website.menus.first.try('result_set'))
        @site_page = @current_website.menus.first
        @page = @site_page.try('page')
        @result_set = @site_page.try('result_set')
        unless @result_set.blank?
          search ||= Search.new(setting_searching_params(:from_params => @result_set.make_params))
          @results ||= search.do_search
        end
      # Find the title_sanitized in menu tree 
      elsif params[:title_sanitized] && @current_website.menus.exists?(:title_sanitized => params[:title_sanitized])
        @site_page = @current_website.menus.find(:first, :conditions => {:title_sanitized => params[:title_sanitized]})
        @page = @site_page.try('page')
        @result_set = @site_page.try('result_set')
        unless @result_set.blank?
          search ||= Search.new(setting_searching_params(:from_params => @result_set.make_params))
          @results ||= search.do_search
        end
      end
      # If page or resultset is found render the page partial else the pages does not exist
      unless @page.blank? && @result_set.blank? && @site_page.blank?
        render :partial => 'page', :layout => 'websites/application'
      else
        render :text => "OOPS! <br /> The page you are looking for does not exist or has been removed", :layout => 'websites/application'
      end
    # Print the status layout
    elsif current_website
      render :template => "#{RAILS_ROOT}/public/#{@current_website.website_state}.html", :layout => false
    # Else render the admin login
    else
      redirect_to admin_root_path
    end
  end

  def show
    if params[:item_type] && params[:id] && current_website
      @item = @current_website.send(params[:item_type].pluralize).find_by_title_sanitized(params[:id])
      if @item
        render :partial => 'show', :layout => 'websites/application'
      else
        render :text => "OOPS! <br /> The page you are looking for does not exist or has been removed", :layout => 'websites/application'
      end
    end
  end
  
  def update
    @page = Page.find(params[:id])
    @page.update_attribute(:body, params[:content])
    render :nothing => true
  end

  protected

  def check_for_page_type
    if @page.page_type == 'gallery'
		  @pictures = @current_website.images.published
			@partial_to_render = 'websites/gallery'
		elsif @page.page_type == 'contact'
		  @person = session[:person] || Person.new
			@email_values = session[:email] || {}
			session[:person] = nil
			session[:email] = nil
			@partial_to_render = 'websites/contact'
		elsif  @page.page_type == 'guestbook'
			@person = session[:person] || Person.new
			@email_values = session[:email] || {}
			session[:person] = nil
			session[:email] = nil
			@guestbook_messages = DataPerson.find(:all, :conditions => {:workspace_id => @current_website.creator.private_workspace.id, :state => 'validated', :origin => 'guestbook_form'}, :order => 'created_at DESC')
      @partial_to_render = 'websites/guestbook'
		end
  end
end

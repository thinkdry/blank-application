class WebsitesController < ApplicationController

  #layout 'websites/application'

  def index
    # Check website url exists & get website object
    if current_website && @current_website.website_state == 'published' 
      # Get the first page of the website tree if there is no title_sinatized
      if params[:title_sanitized].nil? && (@current_website.menus.first.try('page') || @current_website.menus.first.try('result_set'))
        @menu = @current_website.menus.first
        @page = @menu.try('page')
        @result_set = @menu.try('result_set')
        unless @result_set.blank?
          search ||= Search.new(setting_searching_params(:from_params => @result_set.make_params))
          @results ||= search.do_search
        end
        if @page
          check_for_page_type 
        else
          @page = @result_set
        end
      # Find the title_sanitized in menu tree 
      elsif params[:title_sanitized] && @current_website.menus.exists?(:title_sanitized => params[:title_sanitized])
        @menu = @current_website.menus.find(:first, :conditions => {:title_sanitized => params[:title_sanitized]})
        @page = @menu.try('page')
        @result_set = @menu.try('result_set')
        unless @result_set.blank?
          search ||= Search.new(setting_searching_params(:from_params => @result_set.make_params))
          @results ||= search.do_search
        end
        if @page
          check_for_page_type 
        else
          @page = @result_set
        end
      end
      render :partial => 'page', :layout => 'websites/application'
    # Else print the layout
    elsif current_website
      render :template => "#{RAILS_ROOT}/public/#{@current_website.website_state}.html", :layout => false
    else
      redirect_to admin_root_path
    end
  end

  def show
    if params[:item_type] && params[:id] && current_website
      @item = params[:item_type].classify.constantize.find(params[:id])
      @page = Page.new(:page_title => @item.title, :description => @item.description)
      render :partial => 'show', :layout => 'websites/application'
    end
  end
  
  def update
    @page = Page.find(params[:id])
    # TODO check if it is saving!
    @page.update_attribute(:body, params[:content])
    render :nothing => true
  end

  def error
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

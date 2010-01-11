class Admin::MenusController < Admin::ApplicationController
  
  def index
    @website = Website.find(params[:website_id])
    @pages = @website.pages.published
    if @website.menus.count > 0
      @menus = @website.menus
    end
  end

  def new
    @website = Website.find(params[:website_id])
    @pages = @website.pages.published
    @menu = Menu.new
    @menu.parent_id = params[:parent_id]
    render :update do |page|
      page.replace_html 'message', :text => ''
      page.replace_html 'menu_form', :partial => 'form', :locals => {:menu => @menu,:pages => @pages}
    end
  end

  def create
    @website = Website.find(params[:website_id])
    @menu = @website.menus.new(params[:menu])
    if params[:parent_id]
      @menu.parent_id = params[:parent_id]
    end
    if @menu.save
      render :update do |page|
        @menus = @website.menus
        page.replace_html 'message', :text => 'Menu Item Created Sucessfully'
        page.replace_html 'menu_form', :text => ''
        page.replace_html 'menu_generator', :partial => 'menu', :locals => { :menus => @menus }
      end
    end
  end

  def edit
    @website = Website.find(params[:website_id])
    @menu = Menu.find(params[:id])
		@pages = @website.pages.published
    render :update do |page|
      page.replace_html 'message', :text => ''
      page.replace_html 'menu_form', :partial => 'form', :locals => {:menu => @menu }
    end
  end

  def update
    @website = Website.find(params[:website_id])
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      render :update do |page|
        @menus = @website.menus
        page.replace_html 'message', :text => 'Menu Item Updated Sucessfully'
        page.replace_html 'menu_form', :text => ''
        page.replace_html 'menu_generator', :partial => 'menu', :locals => {:menus => @menus}
      end
    end
  end

  def destroy
    @website = Website.find(params[:website_id])
    @menu = Menu.find(params[:id])
    if @menu.destroy
      render :update do |page|
        @menus = @website.menus
        page.replace_html 'message', :text => 'Menu Item Deleted'
        page.replace_html 'menu_generator', :partial => 'menu', :locals => {:menus => @menus}
      end
    end
  end

  
end

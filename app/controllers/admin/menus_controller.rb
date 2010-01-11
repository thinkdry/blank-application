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
    
    render :partial => 'form', :locals => {:menu => @menu,:pages => @pages}
  end

  def create
    @website = Website.find(params[:website_id])
    @menu = @website.menus.new(params[:menu])
    if params[:parent_id]
      @menu.parent_id = params[:parent_id]
    end
    if @menu.save
      
      @menus = @website.menus
      
      flash[:notice] = 'Menu Item Created Sucessfully'
      
      respond_to do |format|
        format.js {render :partial => '/admin/menus/update.js', :layout => false}
      end
    end
  end

  def edit
    @website = Website.find(params[:website_id])
    @menu = Menu.find(params[:id])
		@pages = @website.pages.published
		
		render :partial => 'form', :locals => {:menu => @menu }
  end

  def update
    @website = Website.find(params[:website_id])
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      @menus = @website.menus
      
      flash[:notice] = 'Menu Item Updated Sucessfully'
      
      respond_to do |format|
        format.js {render :partial => '/admin/menus/update.js', :layout => false}
      end
    end
  end

  def destroy
    @website = Website.find(params[:website_id])
    @menu = Menu.find(params[:id])
    if @menu.destroy
       
      flash[:notice] = 'Menu Item Updated Sucessfully'
        
      @menus = @website.menus
        
      respond_to do |format|
        format.js {render :partial => '/admin/menus/update.js', :layout => false}
      end
    end
  end
end
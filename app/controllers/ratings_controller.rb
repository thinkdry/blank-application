class RatingsController < ApplicationController

  def index
    conditions = (!params[:item_type].nil? && params[:item_type] != 'All') ? "rateable_type ='#{params[:item_type].camelize}'" : ''
    if @current_user.has_system_role('superadmin')
      @paginated_objects = Rating.find(:all, :conditions => ["#{conditions}"], :order => 'updated_at DESC').paginate(:per_page => get_per_page_value, :page => params[:page])
    else
      @paginated_objects = Rating.find(:all, :conditions => ["user_id = #{@current_user.id}#{conditions !='' ? ' AND '+conditions : ''}"], :order => 'updated_at DESC').paginate(:per_page => get_per_page_value, :page => params[:page])
    end
    respond_to do |format|
			format.html
#			format.xml { render :xml => @paginated_objects }
    end
  end

end

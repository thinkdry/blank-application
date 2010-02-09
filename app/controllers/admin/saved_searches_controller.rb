class Admin::SavedSearchesController < Admin::ApplicationController
  
  acts_as_ajax_validation

  make_resourceful do 
    actions :create, :index, :destroy

    before :create do
      @current_object.user_id = current_user.id
    end

    after :index do
      @current_objects = current_user.saved_searches.find(:all)
    end

    response_for :create do |format|
      format.html { redirect_to admin_saved_searches_path}
    end

    def current_objects
      @current_objects ||= current_user.current_model.find(:all, :order => "created_at DESC")
    end

  end

  def results
    @saved_search = SavedSearch.find(params[:id])
    @search = Search.new(setting_searching_params(:from_params => @saved_search.make_params))
    @paginated_objects = @current_objects = @search.do_search 
    respond_to do |format|
	 	  format.html { render :template => "admin/searches/index.html.erb" }
			format.xml { render :xml => @paginated_objects }
			format.json { render :json => @paginated_objects }
			format.atom { render :template => "#{@templatee}.atom.builder", :layout => false }
		end
  end
  
end

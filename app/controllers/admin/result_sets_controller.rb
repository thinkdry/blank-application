class Admin::ResultSetsController < Admin::ApplicationController
  acts_as_item

  def results
    @result_set = ResultSet.find(params[:id])
    @search = Search.new(setting_searching_params(:from_params => @result_set.make_params))
    @paginated_objects = @current_objects = @search.do_search 
    respond_to do |format|
	 	  format.html { render :template => "admin/searches/index.html.erb" }
			format.xml { render :xml => @paginated_objects }
		end
  end
end

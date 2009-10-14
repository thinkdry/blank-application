class SearchesController < ApplicationController #:nodoc: all

	# Mixin method implementing ajax validation for that controller
  acts_as_ajax_validation

  # Action managing the results found (used also with AJAX call, for pagination or ordering)
	#
	# Usage URL :
	# - GET /searches
	# - GET /searches.xml
  def index
		# Creation of the search object and search do
		@search = Search.new(setting_searching_params(:from_params => params))#.advance_search_fields
    # TODO manage the params to get the good output with f?*%ù£$$ù AJAX
		#@search.skip_res_pag = true if !params[:format].nil? && params[:format] != 'html'
		@paginated_objects = @current_objects = @search.do_search
		# Definition of the template to use to retrieve information
		if @search.category == 'user' || @search.category == 'workspace'
			@templatee = "#{@search.category.pluralize}/index"
		else
      @templatee = "generic_for_items/index"
		end
		# Management of the response depending of the request type
		if !request.xhr?
			respond_to do |format|
	 			format.html { render :template => "searches/index.html.erb" }
				format.xml { render :xml => @paginated_objects }
				format.json { render :json => @paginated_objects }
				format.atom { render :template => "#{@templatee}.atom.builder", :layout => false }
			end
		else
      @no_div = true
			render :partial => @templatee, :layout => false
		end
  end

  # Action to print the advance search partial (used onl with AJAX call)
	#
	# Usage URL :
	# - GET /searches/print_advanced
	def print_advanced
    @search ||= Search.new()
		render :partial => 'advanced_search', :locals => { :category => params[:cat] }
	end
  
end
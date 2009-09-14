class SearchesController < ApplicationController #:nodoc: all
	
  acts_as_ajax_validation

  # Index Page for Search Results with Filtered Results
  def index
		# Params link to AJAX calls
#		if params[:page] || params[:filter_name] || params[:layout]
#			no_layout = true
#		end
		#params[:search] ||= {:category => 'all'}
		#
		set_param = build_hash_from_params(params)
		# Initialisation : default params
		if !params[:m]
			if (params[:cat] == 'all')
				set_param[:models] = available_items_list+['user']+['workspace']
			elsif (params[:cat] == 'item')
				set_param[:models] = available_items_list
			else
				set_param[:models] = [params[:cat]]
			end
		end
#		if params[:search][:full_text_field]
#				params[:search][:filter_name] ||= 'weight'
#		end
#		params[:filter_name] ||= 'created_at'
#		params[:filter_way] ||= 'desc'
#		params[:search].merge!(:filter_name => params[:filter_name], :filter_way => params[:filter_way], :filter_limit => params[:filter_limit])
		@search = Search.new(set_param)

		#raise @search.param.inspect
		@paginated_objects = @current_objects = @search.do_search
		#raise "que pasa"

#		@current_objects = @search.do_search
#		@current_objects = @current_objects.delete_if{ |e| !e.has_permission_for?('show', @current_user)}
#    params[:item_type] ||= @current_objects.first.class.to_s.downcase.pluralize
#		@paginated_objects = @current_objects.paginate(:page => params[:page], :per_page => get_per_page_value)

		if @search.category == 'item'
			@templatee = "generic_for_items/index"
		else
			@templatee = "#{@search.category.pluralize}/index"
		end

		if !request.xhr?
			respond_to do |format|
	 			format.html { render :template => "searches/index.html.erb" }
				format.xml { render :xml => @paginated_objects }
				format.json { render :json => @paginated_objects }
				format.atom { render :template => "generic_for_items/index.atom.builder", :layout => false }
			end
		else
			render :partial => @templatee, :layout => false
		end
  end

  # Print Advance Search Partial
	def print_advanced
    @search ||= Search.new
		render :partial => 'advanced_search', :locals => { :category => params[:cat] }
	end
  
end
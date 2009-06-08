class SearchesController < ApplicationController
	
  acts_as_ajax_validation
  
  def index
		# Params link to AJAX calls
		if params[:page] || params[:filter_name] || params[:layout]
			no_layout = true
		end
		#params[:search] ||= {:category => 'all'}
		# Initialisation : default params
		if !params[:search][:models]
			if (params[:search][:category] == 'all')
				params[:search][:models] = available_items_list+['user']+['workspace']
			elsif (params[:search][:category] == 'item')
				params[:search][:models] = available_items_list
			else
				params[:search][:models] = [params[:search][:category]]
			end
		end
		if params[:search][:full_text_field]
				params[:search][:filter_name] ||= 'weight'
		end
		params[:filter_name] ||= 'created_at'
		params[:filter_way] ||= 'desc'
		params[:search].merge!(:filter_name => params[:filter_name], :filter_way => params[:filter_way], :filter_limit => params[:filter_limit])
		@search = Search.new(params[:search])
		
		@current_objects = @search.do_search
		@current_objects = @current_objects.delete_if{ |e| !e.accepts_show_for?(@current_user)}
    params[:item_type] ||= @current_objects.first.class.to_s.downcase.pluralize
		@paginated_objects = @current_objects.paginate(:page => params[:page], :per_page => get_per_page_value)

		if no_layout.nil?
			respond_to do |format|
				format.html {  }
				format.xml { render :xml => @current_objects }
				format.json { render :json => @current_objects }
				format.atom { render :template => "items/index.atom.builder", :layout => false }
			end
		else
			render :partial => 'items/items_list', :locals => { :ajax_url => searches_path }
		end
  end

	def print_advanced
		render :partial => 'advanced_search', :locals => { :category => params[:search][:category] }
	end
  
end
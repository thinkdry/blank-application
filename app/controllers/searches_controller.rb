class SearchesController < ApplicationController
	
  acts_as_ajax_validation
  
  def index
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
		params[:filter_limit] ||= 15
		params[:search].merge(params[:filter_name], params[:filter_way], params[:filter_limit])
		@search = Search.new(params[:search])
		
		@results = @search.do_search
		@results = @results.delete_if{ |e| !e.accepts_show_for?(@current_user)}
		@paginated_results = @results.paginate(:page => params[:page], :per_page => 2)
  end

	def print_advanced
		render :partial => 'advanced_search', :locals => { :category => params[:search][:category] }
	end
  
end
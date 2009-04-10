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
		params[:search][:filter_name] ||= 'created_at'
		params[:search][:filter_way] ||= 'desc'
		params[:search][:filter_limit] ||= 15

		@search = Search.new(params[:search])
		
		@results = @search.do_search
		@results = @results.delete_if{ |e| !e.accepts_show_for?(@current_user)}
		@paginated_results = @results.paginate(:page => params[:page], :per_page => 10)
  end

	def print_advanced
		render :partial => 'advanced_search', :locals => { :category => params[:search][:category] }
	end
  
end
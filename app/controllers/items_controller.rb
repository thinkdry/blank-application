class ItemsController < ApplicationController

  # Items Index Page(Content Page) for Showing Items By Category
  def index
		params[:item_type] ||= get_allowed_item_types(current_workspace).first.pluralize
		@current_objects = get_items_list(params[:item_type], current_workspace)
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
		respond_to do |format|
			format.html
			format.xml { render :xml => @current_objects }
			format.json { render :json => @current_objects }
			format.atom { render :template => "items/index.atom.builder", :layout => false }
		end
  end

  # Ajax Pagination for Items for selected Item type
  def ajax_index
		params[:item_type] ||= get_allowed_item_types(current_workspace).first.pluralize
		@current_objects = get_items_list(params[:item_type], current_workspace)
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
    @i = 0
		render :partial => "items/items_list", :layout => false, :locals => { :ajax_url => current_workspace ? "/workspaces/#{current_workspace.id}/ajax_content/"+params[:item_type] : "/ajax_content/#{params[:item_type]}" }
		#render :text => display_item_in_list(@paginated_objects), :layout => false
  end

	# TODO do something clean, this is too much, take a look in the view to understand ...

  # Displaying Items in Pop Up Window for FCKEditor for defined Item Type
  def display_item_in_pop_up
    if params[:selected_item] == 'all' || params[:item_type] == 'all'
      params[:item_type] = 'all'
    end
    if params[:content] != 'all'
			# why params[:workspace_id] ???
      params[:workspace_id] ||= session[:fck_item_type].classify.constantize.find(session[:fck_item_id]).workspaces.first.id
			#raise params[:workspace_id].workspaces.size.inspect
      @workspace = Workspace.find(params[:workspace_id])
      params[:selected_item] = get_allowed_item_types(@workspace).first.pluralize if params[:selected_item].nil? || params[:selected_item] == 'all'
      if !params[:workspace_id].to_s.blank?
        @current_objects = get_items_list(params[:selected_item], @workspace)
      else
        render :text => "No workspace"
        return
      end
    else
      @current_objects = get_items_list(params[:selected_item], nil)
    end
    @base_url = request.url.split(request.request_uri())[0]
    render :layout => 'pop_up', :object => @current_objects
  end
end
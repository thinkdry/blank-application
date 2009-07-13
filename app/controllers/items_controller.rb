class ItemsController < ApplicationController

  # Items Index Page(Content Page) for Showing Items By Category
  #
  # Usage URL:
  #
  # /content/:item_type
  #
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
  #
  # Usage URL:
  #
  # /ajax_content/:item_type
  #
  def ajax_index
		params[:item_type] ||= get_allowed_item_types(current_workspace).first.pluralize
		@current_objects = get_items_list(params[:item_type], current_workspace)
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
    @i = 0
		render :partial => "items/items_list", :layout => false, :locals => { :ajax_url => current_workspace ? "/workspaces/#{current_workspace.id}/ajax_content/"+params[:item_type] : "/ajax_content/#{params[:item_type]}" }
		#render :text => display_item_in_list(@paginated_objects), :layout => false
  end

  # Displaying Items in Pop Up Window for FCKEditor for defined Item Type
  # 
  # Usage URL
  # 
  # '/display_content_list/:selected_item
  #
  def display_item_in_pop_up
    @workspace = (params[:workspace_id] && !params[:workspace_id].blank?) ? Workspace.find(params[:workspace_id]) : nil
		@workspaces = current_user.has_system_role('superadmin') ? Workspace.all : current_user.workspaces
		if params[:selected_item] == 'all'
			@selected_item_types = get_fcke_item_types
			@item_types = (item_types_allowed_to(current_user, 'show', @workspace)&@selected_item_types)
			params[:item_type] ||= @item_types.first
      if params[:item_type]
        @current_objects = get_items_list(params[:item_type], @workspace)
      else
        render :text => "No item types available for your profil."
        return
      end
		elsif (params[:selected_item] == 'images' || params[:selected_item] == 'videos')
			@selected_item_types = [params[:selected_item].to_s.singularize]
			params[:item_type] ||= @selected_item_types.first
			if !params[:item_type].include?('fcke')
				@current_objects = get_items_list(params[:selected_item], @workspace)
			else
				@fcke_objects = []
				if session[:fck_item_type] != 'Page'
					Dir["public/uploaded_files/#{session[:fck_item_type].singularize.downcase}/#{session[:fck_item_id]}/fck_#{params[:selected_item]}/*.*"].collect do |uploaded_image|
						@fcke_objects << { :name => uploaded_image.split('/')[5], :url => root_url+uploaded_image.split('public/')[1] }
					end
				else
					object = session[:fck_item_type].classify.constantize.find(session[:fck_item_id])
					workspace = object.workspaces.delete_if{ |e| e.state == 'private' }.first
					Dir["public/uploaded_files/workspace/#{workspace.id}/fck_#{params[:selected_item]}/*.*"].collect do |uploaded_image|
						@fcke_objects << { :name => uploaded_image.split('/')[5], :url => root_url+uploaded_image.split('public/')[1] }
					end
				end
			end
		else
				###
		end
		#if @current_objects.first
			render :layout => 'pop_up', :object => @current_objects
		#else
		#	render :update do |page|
		#		page.replace_html('abc', :text => 'No results for these criterions.')
		#	end
		#end
  end
end
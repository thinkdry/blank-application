module ActsAsItem
  module UrlHelpers
    def self.included(base)
      define_prefixed_item_paths(base)
  	  base.helper_method \
  	    :current_workspace,
    	  :item_path,
    	  :items_path,
    	  :new_item_path,
    	  :edit_item_path,
    	  :rate_item_path,
    	  :add_tag_item_path,
    	  :remove_tag_item_path,
    	  :add_comment_item_path,
        :ajax_items_path
    end

    # Check for Worksapce
    #
    # can be called from anywhere to check if the user is inside a workspace.
    #
    # Will return the workspace object if workspace parameter exists else will return nil
    def current_workspace
      get_ws = Proc.new do
        params['workspace_id'] ? 
          Workspace.find(params['workspace_id'].to_i) :
          nil
      end
      
      if @workspace
        # Hack: Workspace may be "Workspace.new"
        return @workspace if @workspace.id
        return get_ws.call
      end
      return @current_object if @current_object && @current_object.class == Workspace
      @workspace = get_ws.call
    end

    # Show Url for given Item Object
    #
    # Usage:
    #
    # <tt>item_path(article)</tt>
    #
    # will return /articles/1
    #
    # Parameters:
    #
    # - model: Article,Image,Audio,Video.... (may be any Item type)
    def item_path object, params = {}
      prefix = params.delete :prefix

      helper_name = String.new
      helper_name += prefix + '_' if prefix
      helper_name += "admin_"
      helper_name += 'workspace_' if current_workspace
      helper_name += object.class.to_s.underscore + '_path'
      args = [object, params]
      args.insert(0, current_workspace) if current_workspace

      send helper_name, *args
    end

    # New Url for given Item Object
    #
    # Usage:
    #
    # <tt>new_item_path(article_object)</tt>
    #
    # will return /articles/new
    #
    # Parameters:
    #
    # - model: Article,Image,Audio,Video.... (may be any Item type)
    def new_item_path(model)
      helper_name = 'new_admin_'
      helper_name += 'workspace_' if current_workspace
      helper_name += model.to_s.underscore + '_path'
      args = current_workspace ? [current_workspace] : []
      send(helper_name, *args)
    end

    # Edit Url for given Item Object
    #
    # Usage:
    #
    # <tt>edit_item_path(article_object)</tt>
    #
    #  will return /articles/1/edit
    #
    # Parameters:
    #
    # - model: Article,Image,Audio,Video.... (may be any Item type)
		def edit_item_path(model)
      helper_name = 'edit_admin_'
      helper_name += 'workspace_' if current_workspace
      helper_name += model.to_s.underscore + '_path'
      args = current_workspace ? [current_workspace] : []
      send(helper_name, *args)
    end

    # Index Url for given Item Object
    #
    # Usage:
    #
    # <tt>items_path(article_object)</tt>
    #
    # will return /articles
    #
    # Parameters:
    #
    # - model: Article,Image,Audio,Video.... (may be any Item type)
    def items_path(model)
      model = model.table_name unless model.is_a?(String)  
      if current_workspace
				admin_workspace_url(current_workspace.id)+"/#{model.underscore.pluralize}"
      else
        admin_root_url+"/#{model.underscore.pluralize}"
      end
    end

		# Content Tabs Url for given Item Object
		# This allow you to switch, easier than the simple index, between the different items list.
    #
    # Usage:
    #
    # <tt>content_path(article_object)</tt>
    #
    # will return /content/articles
    #
    # Parameters:
    #
    # - model: Article,Image,Audio,Video.... (may be any Item type)
		def content_path(model)
			if current_workspace
				admin_workspace_url(current_workspace.id)+"?item_type=#{model.underscore.pluralize}"
      else
        admin_content_url(:item_type => model.underscore.pluralize)
      end
		end

    # Dynamically create Item path for given Item for Pagination
    #
    # Usage:
    #
    # <tt>ajax_items_path(Article)</tt>
    #
    # will return  "http://www.example.com/workspaces/1/ajax_content/Article" inside workspace
    #
    # else will return  "http://www.example.com/ajax_content/Article"
    #
    # Parameters:
    #
    # - model: Article,Image,Audio,Video.... (may be any Item type)
    def ajax_items_path(model)
      model = model.table_name unless model.is_a?(String)
      if current_workspace
        admin_workspace_ajax_content_url(:workspace_id => current_workspace.id, :item_type => model)
      else
        admin_ajax_content_url(:item_type => model)
      end
    end

    private
    def self.define_prefixed_item_paths(base)
      # OPTIMIZE: Import prefix list from a conf file
       ['edit', 'rate', 'add_tag', 'remove_tag', 'add_comment'].each do |prefix|
         base.send(:define_method, "#{prefix}_item_path") do |*args|
           object, params = args[0], args[1] || {}
           params[:prefix] = prefix
           item_path(object, params)
         end
       end
    end
  end
end
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

    # Return Worksapce Object
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
    # item_path(article_object) => /articles/1
    def item_path object, params = {}
      prefix = params.delete :prefix

      helper_name = String.new
      helper_name += prefix + '_' if prefix
      helper_name += 'workspace_' if current_workspace
      helper_name += object.class.to_s.underscore + '_path'

      args = [object, params]
      args.insert(0, current_workspace) if current_workspace

      send helper_name, *args
    end

    # New Url for given Item Object
    #
    # Usage:
    # new_item_path(article_object) => /articles/new
    def new_item_path(model)
      helper_name = 'new_'
      helper_name += 'workspace_' if current_workspace
      helper_name += model.to_s.underscore + '_path'
      args = current_workspace ? [current_workspace] : []
      send(helper_name, *args)
    end

    # Edit Url for given Item Object
    #
    # Usage:
    # edit_item_path(article_object) => /articles/1/edit
		def edit_item_path(model)
      helper_name = 'edit_'
      helper_name += 'workspace_' if current_workspace
      helper_name += model.to_s.underscore + '_path'
      args = current_workspace ? [current_workspace] : []
      send(helper_name, *args)
    end

    # Index Url for given Item Object
    #
    # Usage:
    # items_path(article_object) => /articles
    def items_path(model)
      model = model.table_name unless model.is_a?(String)  
      if current_workspace
        workspace_content_url(:workspace_id => current_workspace.id, :item_type => model.underscore.pluralize)
      else
        content_url(:item_type => model.underscore.pluralize)
      end
    end

    # Dynamically create Item path for given Item for Pagination
     def ajax_items_path(model)
      model = model.table_name unless model.is_a?(String)
      if current_workspace
        workspace_ajax_content_url(:workspace_id => current_workspace.id, :item_type => model)
      else
        ajax_content_url(:item_type => model)
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
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
    	  :comment_item_path
    end

    def current_workspace
      return @workspace if @workspace
      return @current_object if @current_object && @current_object.class == Workspace
      if params['workspace_id']
        @workspace = Workspace.find(params['workspace_id'].to_i)
        return @workspace
      end
      nil
    end

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

    def new_item_path(model)
      helper_name = 'new_'
      helper_name += 'workspace_' if current_workspace
      helper_name += model.to_s.underscore + '_path'
      args = current_workspace ? [current_workspace] : []
      send(helper_name, *args)
    end

    def items_path(model)
      model = model.table_name unless model.is_a?(String)  
      if current_workspace
        workspace_content_url(current_workspace.id, :page => model)
      else
        content_url(:page => model)
      end
    end

    private
    def self.define_prefixed_item_paths(base)
      # OPTIMIZE: Import prefix list from a conf file
       ['edit', 'rate', 'add_tag', 'remove_tag', 'comment'].each do |prefix|
         base.send(:define_method, "#{prefix}_item_path") do |*args|
           object, params = args[0], args[1] || {}
           params[:prefix] = prefix
           item_path(object, params)
         end
       end
    end
  end
end
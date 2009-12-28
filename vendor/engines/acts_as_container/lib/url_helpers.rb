module ActsAsContainer
  module UrlHelpers
    def self.included(base)
  	  base.helper_method \
        :current_container,
    	  :container_path,
    	  :containers_path,
    	  :new_container_path,
    	  :edit_container_path,
        :new_container_item_path,
        :ajax_container_path,
        :add_new_user_container_path
    end

    def current_container
      container = nil
      CONTAINERS.each do |con|
        if params["#{con}_id".to_sym]
          container = con.classify.constantize.find(params["#{con}_id"].to_i)
          break
        elsif params[:controller].split('/')[1] == con.pluralize && params[:id]
          container = con.classify.constantize.find(params[:id].to_i)
          break
        end
      end
      container ? container : @current_user.private_workspace
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
    def container_path object, params = {}
      helper_name = String.new
      helper_name += 'admin_'
      helper_name += object.class.to_s.underscore + '_path'
      args = [object, params]
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
    def new_container_path(model)
      helper_name = 'new_admin_'
      helper_name += model.to_s.underscore + '_path'
      send(helper_name)
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
		def edit_container_path(object)
      helper_name = 'edit_admin_'
      helper_name += object.class.to_s.downcase.underscore + '_path'
      args = [object]
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
    def containers_path(model)
      model = model.table_name unless model.is_a?(String)
      admin_root_url+"/#{model.underscore.pluralize}"
    end

    def new_container_item_path(container,item)
      helper = String.new
      helper += 'new_admin_'
      helper += "#{container}_#{item}_path"
      args = [container]
      send(helper, *args)
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
    def ajax_container_path(model)
      model = model.table_name unless model.is_a?(String)
      admin_ajax_content_url(:container => model)
    end

    def add_new_user_container_path(container, id)
      helper = String.new
      helper += "add_new_user_admin_#{container}_path"
      args = [id]
      send(helper, *args)
    end

  end
end

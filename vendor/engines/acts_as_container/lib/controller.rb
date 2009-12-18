# This module is defining the different methods and actions required by an Object controller to acts like an Item.
# It is so defining the mixin method that will include all these required methods and actions inside this Object controller.
#
module ActsAsContainer
  module ControllerMethods

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_container &block
				# Declaration of the AjaxValidation plugin
				acts_as_ajax_validation
				# Filter allowing to update the Xapian index with the delta brought by that object (Superfast solution, but performance less)
				after_filter :only => [:create, :update, :destroy] do
					Thread.new do
						system("rake xapian:update_index RAILS_ENV=#{RAILS_ENV}")
					end
				end

        make_resourceful do
          actions :all, :except => [:index]

          # Inclusion of the block if a block is found
          self.instance_eval(&block) if block_given?

          before :show do
            params[:id] ||= params["#{@current_object.class.to_s.downcase}_id".to_sym]
            if current_container
              params[:item_type] ||= get_allowed_item_types(current_container).first.pluralize
              params[:container_type] ||= current_container.class.to_s.downcase
              params[:container_id] ||= current_container.id
            end
            if !params[:item_type].blank?
              @paginated_objects = params[:item_type].classify.constantize.get_da_objects_list(setting_searching_params(:from_params => params))
            end
          end

          before :create do
            params[:id] ||= params["#{@current_object.class.to_s.downcase}_id".to_sym]
            @current_object.ws_items = available_items_list.join(",")
            @current_object.creator = @current_user
          end
          after :create do
            flash[:notice] = t("container.#{@current_object.class.to_s.downcase}").singularize + " " + t("container.messages.created")
          end
          after :create_fails do
            flash.now[:error] = t("container.#{@current_object.class.to_s.downcase}").singularize + " " + t("container.messages.create_failed")
          end

          after :update do
            flash[:notice] = t("container.#{@current_object.class.to_s.downcase}").singularize + " " +  t("container.messages.updated")
          end
          after :update_fails do
            flash.now[:error] = t("container.#{@current_object.class.to_s.downcase}").singularize + " " +  t("container.messages.update_failed")
          end

          response_for :destroy do |format|
            format.html { redirect_to containers_path(@current_object.class.to_s) }
          end

          response_for :new, :create_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/new.html.erb') ? params[:controller]+'/new.html.erb' : 'containers/new.html.erb')) }
					end

					response_for :edit, :update_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/edit.html.erb') ? params[:controller]+'/edit.html.erb' : 'containers/edit.html.erb')) }
					end

          response_for :show do |format|
            format.html{render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/show.html.erb') ? params[:controller]+'/show.html.erb' : 'containers/show.html.erb'))}
            format.xml { render :xml => @current_object }
            format.json { render :json => @current_object }
            format.atom { render :template => "items/index.atom.builder", :layout => false }
          end
        end
        
        # Inclusion of the instance methods inside the mixin method
        include ActsAsContainer::ControllerMethods::InstanceMethods

      end
    end

    module InstanceMethods

      def current_object
        @current_object ||= @container =
          if params[:id]
          params[:controller].split('/')[1].classify.constantize.find(params[:id])
        elsif p_id = params["#{params[:controller].split('/')[1].singularize}_id".to_sym]
          params[:controller].split('/')[1].classify.constantize.find(p_id.to_i)
        else
          nil
        end
      end
      
      def current_objects
        params_hash = setting_searching_params(:from_params => params)
        params_hash.merge!({:skip_pag => true}) if params[:format] && params[:format] != 'html'
        @current_objects ||= @paginated_objects = params[:controller].split('/')[1].classify.constantize.get_da_objects_list(params_hash)
        #Workspace.allowed_user_with_permission(@current_user, 'workspace_show')
      end

      def index
        current_objects
        if !request.xhr?
          @no_div = false
          respond_to do |format|
            format.html {render :template => "containers/index.html.erb"}
            format.xml { render :xml => @paginated_objects }
            format.json { render :json => @paginated_objects }
            format.atom {render :template => "containers/index.atom.builder", :layout => false }
          end
        else
          @no_div = true
          render :partial => 'containers/index', :layout => false
        end
      end
      
    end
  end
end
module ActsAsItem
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # ActsAsItem Library for Item Specific Code - Specific Controller Methods to All Items
      def acts_as_item &block
        include ActsAsItem::ControllerMethods::InstanceMethods
				acts_as_commentable
				acts_as_keywordable

				# Filter allowing to update the Xapian index with the delta brought by that object (Superfast solution, but performance less)
				after_filter :only => [:create, :update, :destroy] do
					Thread.new do
						system("rake xapian:update_index RAILS_ENV=#{RAILS_ENV}")
					end
				end

        make_resourceful do
          actions :all
          belongs_to :workspace

          self.instance_eval &block if block_given?
          
          after :create do
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.new.flash_notice')
          end

          after :create_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('item.new.flash_error')
          end

          after :update do
            session[:fck_item_id] = nil
            session[:fck_item_type] = nil
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.edit.flash_notice')
          end
          
           after :update_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('item.edit.flash_error')
          end

          before :new, :create do
            no_permission_redirection unless @current_object && @current_object.accepts_new_for?(@current_user)
          end

          before :show do
            no_permission_redirection unless @current_object && @current_object.accepts_show_for?(@current_user)
						@current_object.viewed_number = @current_object.viewed_number.to_i + 1
						@current_object.save
          end

          before :edit, :update do
            no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
						session[:fck_item_id] = @current_object.id
            session[:fck_item_type] = @current_object.class.to_s
          end

          before :destroy do
            no_permission_redirection unless @current_object && @current_object.accepts_destroy_for?(@current_user)
          end

          # Makes `current_user` as author for the current_object
          before :create do
						# Trick used in case there is no params (meaning none is selected)
						params[@current_object.class.to_s.underscore][:categories_field] ||= []
						params[@current_object.class.to_s.underscore][:keywords_field] ||= []
            current_object.user_id = current_user.id
          end

					before :update do
						params[@current_object.class.to_s.underscore][:categories_field] ||= []
						params[@current_object.class.to_s.underscore][:keywords_field] ||= []
					end

					before :index do
						@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
					end

					response_for :new, :create_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/new.html.erb') ? params[:controller]+'/new.html.erb' : 'items/new.html.erb')) }
					end

					response_for :edit, :update_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/edit.html.erb') ? params[:controller]+'/edit.html.erb' : 'items/edit.html.erb')) }
					end

					response_for :show do |format|
						format.html # index.html.erb
						format.xml { render :xml => @current_object }
						format.json { render :json => @current_object }
	        end

					response_for :index do |format|
						format.html { render :template => 'items/index_for_item.html.erb' }
						format.xml { render :xml => @current_objects }
						format.json { render :json => @current_objects }
						format.atom { render :template => "items/index.atom.builder", :layout => false }
	        end

          response_for :destroy do |format|
            format.html { redirect_to(items_path(params[:controller])) }
          end
          
#					response_for :update do |format|
#						#format.html { redirect_to item_path(@current_object)}
#						format.html { redirect_to((ws=current_workspace) ? workspace_path(ws.id)+"/#{@current_object.class.to_s.underscore.pluralize}" : "/content/#{@current_object.class.to_s.underscore.pluralize}") }
#					end

#					response_for :create do |format|
#							format.html {
#								#redirect_to( ((@current_object.class.to_s == 'Article') || (@current_object.class.to_s == 'Page')) ? ((ws=current_workspace) ? edit_item_path(@current_object.class.to_s) : "/content/#{@current_object.class.to_s.underscore.pluralize}/#{@current_object.id}/edit") : ((ws=current_workspace) ? workspace_path(ws.id)+"/#{@current_object.class.to_s.underscore.pluralize}"+"/#{@current_object.id}/edit" : "/content/#{@current_object.class.to_s.underscore.pluralize}"+"/#{@current_object.id}/edit") )
#								#raise @current_object.class.to_s.inspect
#								if ((@current_object.class.to_s == 'Article') || (@current_object.class.to_s == 'Page'))
#									redirect_to((ws=current_workspace) ? workspace_path(ws.id)+"/#{@current_object.class.to_s.underscore.pluralize}/#{@current_object.id}/edit" : "/#{@current_object.class.to_s.underscore.pluralize}/#{@current_object.id}/edit")
#								else
#									redirect_to((ws=current_workspace) ? workspace_path(ws.id)+"/#{@current_object.class.to_s.underscore.pluralize}"+"/#{@current_object.id}" : "/#{@current_object.class.to_s.underscore.pluralize}"+"/#{@current_object.id}")
#								end
#							}
#					end
					
        end

        # Return The Items List depending on current controller
				def current_objects
					@current_objects = get_items_list(params[:controller])
				end

				

      end

    end
    
    module InstanceMethods
      # Add Rating to the Current Item
      def rate
        current_object.add_rating(Rating.new(:rating => params[:rated].to_i))
				current_object.rates_average = current_object.rating
				current_object.save
				# TODO : refresh the rate box ...
        render :nothing => true
      end
      
    end
  end
end
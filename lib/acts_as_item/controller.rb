module ActsAsItem
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_item &block
        include ActsAsItem::ControllerMethods::InstanceMethods
				acts_as_commentable
				acts_as_keywordable
        
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
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.edit.flash_notice')
          end
          
           after :update_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('item.edit.flash_error')
          end

          before :new, :create do
            no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
          end

          before :show do
            no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
						@current_object.viewed_number = @current_object.viewed_number.to_i + 1
						@current_object.save
          end

          before :edit, :update do
            no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
          end

          before :destroy do
            no_permission_redirection unless @current_object.accepts_destroy_for?(@current_user)
          end

					after :index do
						@current_objects = current_model.list_items_with_permission_for(@current_user, 'show', current_workspace).paginate(:per_page => 20, :page => params[:page])
					end

          # Makes `current_user` as author for the current_object
          before :create do
						params[@current_object.class.to_s.underscore][:categories_field] ||= []
						params[@current_object.class.to_s.underscore][:keywords_field] ||= []
            current_object.user_id = current_user.id
          end

					before :update do
						params[@current_object.class.to_s.underscore][:categories_field] ||= []
						params[@current_object.class.to_s.underscore][:keywords_field] ||= []
					end
					
					response_for :show do |format|
						format.html # index.html.erb
						format.xml { render :xml => @current_object }
						format.json { render :json => @current_object }
	        end

					response_for :index do |format|
						format.html { redirect_to(items_path(params[:controller])) }
						format.xml { render :xml => @current_objects }
						format.json { render :json => @current_objects }
						format.atom { render :template => 'adverts/index.atom.builder', :layout => false }
	        end
					
        end
      end
    end
    
    module InstanceMethods
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
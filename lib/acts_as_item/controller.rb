module ActsAsItem
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_item &block
        include ActsAsItem::ControllerMethods::InstanceMethods
        
      	make_resourceful do
          actions :all
      		belongs_to :workspace

          self.instance_eval &block if block_given?
          
          # TODO: Items related roles
          # ROLES DESCRIPTION
          # New - Create:   Any User
          #                 WS assignation: Writer, Moderator or Creator of WS
          # Show:           Admin, Author or Member of one assigned WS
          # Edit - Update:  Admin, Author, Creator or Moderator of WS
          # Remove:         Admin, Author
        	
        	# Makes `current_user` as author for the current_object
        	before :create do
        	  current_object.user = current_user
      	  end
					
					before :index do
						@current_objects = current_objects.paginate(
						:page => params[:page],
						:order => :title,
						:per_page => 2
					)
					end			
        end
      end
    end
    
    module InstanceMethods
      def rate
        current_object.add_rating(Rating.new(:rating => params[:rated].to_i))
        render :nothing => true
      end
      
      def add_tag
        tag_name = params[:tag]['name']
        tag = Tag.find_by_name(tag_name) || Tag.create(:name => tag_name)
        current_object.taggings.create(:tag => tag)
        render :update do |page|
          page.insert_html :bottom, 'tag_list', ' ' + item_tag(tag)
        end
      end
      
      def comment
        comment = current_object.comments.create(params[:comment].merge(:user => @current_user))
        render :update do |page|
          page.insert_html :bottom, 'comment_list', :partial => "items/comment", :object => comment
        end
      end
      
      def remove_tag
        tag = current_object.taggings.find_by_tag_id(params[:tag_id].to_i)
        tag_dom_id = "tag_#{tag.tag_id}"
        tag.destroy
        render :update do |page|
          page.remove tag_dom_id
        end
      end
    end
  end
end
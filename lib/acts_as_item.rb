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

          # Permissions related callbacks
          before :create, :new, :index do
        	  permit "member of workspace" if @workspace
        	end
        	before :edit, :update, :delete do
        	  permit "edit of current_object"
      	  end
      	  before :delete do
      	    permit "delete of current_object"
    	    end
        	
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
  
  module ModelMethods
     def validate
           errors.add(:description, "Cannot Be Blank") if (description=="<br>")
      end
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def item?
        return true if self.respond_to?(:item)
        false
      end
      
      def acts_as_item
        acts_as_rateable
        
        belongs_to :user
        has_many :taggings, :as => :taggable
        has_many :tags,     :through => :taggings
        has_many :comments, :as => :commentable, :order => 'created_at ASC'
        
        include ActsAsItem::ModelMethods::InstanceMethods
      end
      
      def icon
        'item_icons/' + self.to_s.underscore + '.png'
      end
    end
    
    module InstanceMethods
      def icon
         self.class.icon
      end
      
      def string_tags= arg # Take a list of tag, space separated and assign them to the object
        @string_tags = arg
        arg.split(' ').each do |tag_name|
          tag = Tag.find_by_name(tag_name) || Tag.new(:name => tag_name)
          self.taggings.build(:tag => tag)
        end
      end
      
      def string_tags # Return space separated tag names
        return @string_tags if @string_tags
        tags.collect { |t| t.name }.join(' ') if tags && tags.size > 0
      end
      
      def associated_workspaces= workspace_ids
    		self.workspaces.delete_all
    		workspace_ids.each { |w| self.items.build(:workspace_id => w) }
      end
      
      def accepts_role? role, user
    	  begin
    	    if %W(edit delete author).include? role
    	      return(true) if self.user == user
      	  else
      	    return(false)
    	    end
    	  rescue Exception => e
    	    p e
    	    raise e
    	  end
      end
    end
        
  end
end


module ActsAsItem
  module ModelMethods
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
    	    auth_method = "accepts_#{role.downcase}?"
    	    return (send(auth_method, user)) if defined?(auth_method)
    	    raise("Auth method not defined")
    	  rescue Exception => e
    	    p(e) and raise(e)
    	  end
      end
      
      private
      # Is user authorized to consult this item?
      def accepts_consultation? user
        # Admin
        return true if user.is_admin?
        # Author
        return true if self.user = user
        # Member of one assigned WS
        self.workspaces.each do |ws|
          return true if ws.users.include?(user)
        end
        false
      end
      
      # Is user authorized to delete this item?
      def accepts_deletion? user
        # Admin
        return true if user.is_admin?
        # Author
        return true if self.user = user
        false
      end
      
      # Is user authorized to edit this item?
      def accepts_edition? user
        # Admin
        return true if user.is_admin?
        # Author
        return true if self.user = user
        # TODO: Allow creator or moderator of WS to edit items
        false
      end
      
      # Is user authorized to create one item?
      def accepts_creation? user
        true if user
      end
    end
  end
end

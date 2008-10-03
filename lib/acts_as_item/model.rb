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
        def validate
          errors.add(:description, "Cannot Be Blank") if (description=="<br>")
        end
        
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
    	    true
    	  rescue Exception => e
    	    p e
    	    raise e
    	  end
      end
    end
  end
end

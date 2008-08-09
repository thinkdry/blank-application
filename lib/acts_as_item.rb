module ActsAsItem
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_item
        
      	make_resourceful do
          actions :all
      		belongs_to :workspace

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
        end
      end
    end
  end
  
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
        include ActsAsItem::ModelMethods::InstanceMethods
      end
    end
    
    module InstanceMethods
      def icon
        'item_icons/' + self.class.to_s.underscore.downcase + '.png'
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


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
        	  permit "author of artic_file"
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
      def acts_as_item
        include ActsAsItem::ModelMethods::InstanceMethods
      end
    end
    
    module InstanceMethods
      def associated_workspaces= workspace_ids
    		self.workspaces.delete_all
    		workspace_ids.each { |w| self.items.build(:workspace_id => w) }
      end
    end
        
  end
end


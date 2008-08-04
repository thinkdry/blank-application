module ActsAsItem
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
      def before_validation_on_create
        debugger
        self.user = @current_user
      end
      
      def associated_workspaces= workspace_ids
    		self.workspaces.delete_all
    		workspace_ids.each { |w| self.items.build(:workspace_id => w) }
      end
    end
        
  end
end


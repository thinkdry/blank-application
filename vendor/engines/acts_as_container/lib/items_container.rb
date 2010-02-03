module ItemsContainer

  module ModelMethods
  
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_items_container
        # Relation 1-N with the 'workspaces' table
        belongs_to "#{self.class_name.split('Items')[1].underscore}".to_sym
        # Polymorphic relation with the items tables
        belongs_to :itemable, :polymorphic => true
        # Include InstanceMethods Module
        include ItemsContainer::ModelMethods::InstanceMethods
      end
    end

    module InstanceMethods
      # Method retreiving the item object using the polymorphic relation
      def get_item #:nodoc:
        return self.itemable_type.classify.constantize.find(self.itemable_id)
      end
      # Method retrieving the title of the item object
      def title #:nodoc:
        return self.get_item.title
      end
      # Method retrieving the title of the description object
      def description #:nodoc:
        return self.get_item.description
      end
    end
  end
end

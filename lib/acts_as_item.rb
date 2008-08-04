module ActsAsItem
  module Controllers
    class ItemController < ApplicationController
      acts_as_ajax_validation

    	make_resourceful do
        actions :all
    		belongs_to :workspace

        before :create, :new, :index do
      	  permit "member of workspace" if @workspace
      	end

      	before :edit, :update, :delete do
      	  debugger
      	  permit "author of artic_file"
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


module ActsAsWorkspace
  module ModelMethods
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def workspace?
        return true if self.respond_to?(:workspace)
        false
      end
      
      def acts_as_workspace
        
        
        
        include ActsAsItem::ModelMethods::InstanceMethods
      end
      
      def icon
        'workspace_icons/' + self.to_s.underscore + '.png'
      end

			def label
				I18n.t("general.worskpace.#{self.model_name.underscore}")
			end

    end
    
    module InstanceMethods
    
      
      # Is user authorized to consult this item?
      def accepts_show_for? user
        return accepting_action(user, 'show', false, false, true)
      end

      # Is user authorized to delete this item?
      def accepts_destroy_for? user
        return accepting_action(user, 'show', false, false, true)
      end
      
      # Is user authorized to edit this item?
      def accepts_edit_for? user
        return accepting_action(user, 'show', false, false, true)
      end
      
      # Is user authorized to create one item?
      def accepts_new_for? user
        return accepting_action(user, 'new', false, false, true)
			end

			private
			def accepting_action(user, action, spe_cond, sys_cond, ws_cond)
				 # Special access
				if user.is_superadmin? || spe_cond
					return true
				end
        # System access
				if user.has_system_permission(self.class.to_s.downcase, action) || sys_cond
					return true
				end
        # Workspace access
				# Not for new and index normally ...
				if self.users.include?(user)
					if user.has_workspace_permission(self.id, self.class.to_s.downcase, action) && ws_cond
						return true
					end
				end
			  false
			end
			
    end
  end
end

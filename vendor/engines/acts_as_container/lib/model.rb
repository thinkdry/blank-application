module ActsAsContainer
  module ModelMethods

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_container

        #---------------------------------------------------------
        # Relationships
        
        # Relation N-1 with the 'users_workspaces' table
        has_many :users_containers, :as => :containerable, :dependent => :delete_all
        # Relation N-1 getting the roles linked to that workspace, through the 'users_workspaces' table
        has_many :roles, :through => :users_containers
        # Relation N-1 getting the users linked to that workspace, through the 'users_workspaces' table
        has_many :users, :through => :users_containers
        # Relation N-1 with the 'items' table
        has_many "items_#{self.name.underscore.pluralize}".to_sym, :dependent => :delete_all
        # Relation N-1 getting the different item types, through the 'items' table
        ITEMS.each do |item|
          has_many item.pluralize.to_sym, :source => :itemable, :through => "items_#{self.name.underscore.pluralize}".to_sym, :source_type => item.classify.to_s, :class_name => item.classify.to_s
        end
        # Relation N-1 getting the FeedItem objects, through the 'feed_sources' table
        has_many :feed_items, :through => :feed_sources
        # Relation 1-N to the 'users' table
        belongs_to :creator, :class_name => 'User'

        #---------------------------------------------------------
        # Validations
        # Validation of the prsence of these fields
        validates_presence_of :title, :description
        # Validate Association with users containers
        validates_associated :users_containers

        # Validation of the uniqueness of users associated to that workspace
        validate :uniqueness_of_users


        #----------------------------------------------------------
        # Rights & Permissions

        acts_as_authorizable

        #----------------------------------------------------------
        # Named Scopes

        # Scope getting the 5 last workspaces created
        named_scope :latest,
          :order => 'created_at DESC',
          :limit => 5

        #---------------------------------------------------------
        # Callback Methods

        # After Updation Save the associated Users in UserWorkspaces
        after_update  :save_users_container

        include ActsAsContainer::ModelMethods::InstanceMethods
      end
    end # End of Class Methods

    module InstanceMethods

      # Method used for the validation of the uniqueness of users linked to the workspace
      def uniqueness_of_users #:nodoc:
        new_users = self.users_containers.collect { |e| e.user }
        new_users.size.times do
          self.errors.add_to_base('Same user added twice') and return if new_users.include?(new_users.pop)
        end
      end

      # Users of the workspace with the defined role
      #
      # This method retrieves the users of the given role in that workspace.
      #
      # Usage :
      # <tt>workspace.users_by_role('ws_admin')</tt>
      #
      # Parameters :
      # - role_name: String defining the role name (ex : 'superadmin', 'reader', ...)
      def users_by_role role_name
        role = self.roles.find_by_name(role_name)
        res = []
        if role
          uc = UsersContainer.find(:all, :conditions => { :role_id => role.id, :containerable_id => self.id, :containerable_type => self.class.to_s })
          uc.each do |e|
            res << e.user
          end
        end
        return res
      end

      # Method setting the item types available for that workspace
      #
      # This method will convert the Array given in parameters in an String, where
      # the different elements of this array are joined by ','.
      #
      # Parameters :
      # - params: Array of Strings defining the item types
      def available_items= params
        self[:available_items] = params.join(',')
      end

      # Method setting the item categories available for that workspace
      #
      # This method will convert the Array given in parameters in an String, where
      # the different elements of this array are joined by ','.
      #
      # Parameters :
      # - params: Array of Strings defining the item categories
      def item_categories= params
        self[:item_categories] = params.join(',')
      end

      # Method setting the available types available for that workspace
      #
      # This method will convert the Array given in parameters in an String, where
      # the different elements of this array are joined by ','.
      #
      # Parameters :
      # - params: Array of Strings defining the available types
      def available_types= params
        self[:available_types] = params.join(',')
      end

      # Link the attributesof Users directly
      def new_user_attributes= user_attributes
        #downcase_user_attributes(user_attributes)
        user_attributes.each do |attributes|
          users_containers.build(attributes)
        end
      end

      # Check if the User is Associated with worksapce or not
      def existing_user_attributes= user_attributes
        #downcase_user_attributes(user_attributes)
        users_containers.reject(&:new_record?).each do |uc|
          attributes = user_attributes[uc.id.to_s]
          attributes ? uc.attributes = attributes : users_containers.delete(uc)
        end
      end
      
      # Save the workspace assocaitions for Users in UsersWorkspace
      def save_users_container
        users_containers.each do |uc|
          uc.save(false)
        end
      end

      private
      def downcase_user_attributes(attributes)
        attributes.each { |value| value['user_login'].downcase! }
      end
    end # End of Instance Methods
  end # End of Model Methods
end

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

				acts_as_xapian :texts => [:title, :description, :tags],
                 :values => [[:created_at, 0, "created_at", :number],[:title, 1, "title", :string], [:comment_size, 2, "commented", :number], [:rate_average, 3, "rated", :number]]

				has_many :items
				has_many :workspaces, :through => :items
        belongs_to :user
        has_many :taggings, :as => :taggable
        has_many :tags,     :through => :taggings
        has_many :comments, :as => :commentable, :order => 'created_at ASC'
        
        validates_presence_of	:title, :description, :user
        # Ensure that item is associated to one or more workspaces throught items table
        validates_presence_of :items, :message => "Sélectionner au moins un espace de travail"
        
        include ActsAsItem::ModelMethods::InstanceMethods
      end
      
      def icon
        'item_icons/' + self.to_s.underscore + '.png'
      end

			def label
				I18n.t("general.item.#{self.model_name.underscore}")
			end

    end
    
    module InstanceMethods

			def commented
				self.comments.size
			end

			def rated
				self.rating.to_i
			end

			def workspace_titles
				self.workspaces.map{ |e| e.title }.join(',')
			end

      def icon
         self.class.icon
      end
      
      def flat_tags
        self[:tags] = self.taggings.collect { |t| t.tag.name }.join(' ')
      end

      def category= category=""
        self[:category] = category.join(",")
      end
      
      # Take a list of tag, space separated and assign them to the object
      def string_tags= arg
        @string_tags = arg
        tag_names = arg.split(' ').uniq
        # Delete all tags that are no more associated
        taggings.each do |tagging|
          tagging.destroy unless tag_names.delete(tagging.tag.name)
        end
        # Insert new tags
        tag_names.each do |tag_name|
          tag = Tag.find_by_name(tag_name) || Tag.new(:name => tag_name)
          self.taggings.build(:tag => tag)
        end
        flat_tags
      end

      def string_tags # Return space separated tag names
        return @string_tags if @string_tags
        self[:tags]
      end
      
      def associated_workspaces= workspace_ids
        self.items = workspace_ids.collect { |id| self.items.build(:workspace_id => id) }
      end
      
      # Is user authorized to consult this item?
      def accepts_show_for? user
        return accepting_action(user, 'show', false, false, true)
      end

      # Is user authorized to delete this item?
      def accepts_destroy_for? user
        return accepting_action(user, 'show', false, false, (self.user == user))
      end
      
      # Is user authorized to edit this item?
      def accepts_edit_for? user
        return accepting_action(user, 'show', false, false, (self.user == user))
      end
      
      # Is user authorized to create one item?
      def accepts_new_for? user
        return accepting_action(user, 'new', false, false, true)
			end

			private
			def accepting_action(user, action, spe_cond, sys_cond, ws_cond)
				 # Special access
				if user.has_system_role('superadmin') || spe_cond
					return true
				end
        # System access
				if user.has_system_permission(self.class.to_s.downcase, action) || sys_cond
					return true
				end
        # Workspace access
				if action=='new'
					ws = user.workspaces
				else
					ws = self.workspaces
				end
        ws.each do |ws|
          if ws.users.include?(user)
						if user.has_workspace_permission(ws.id, self.class.to_s.downcase, action) && ws_cond
							return true
						end
					end
        end
        false
			end
			
    end
  end
end

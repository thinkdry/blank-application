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

			def list_items_with_permission_for(user, action, workspace=false)
				if (workspace)
					if workspace.ws_items.include?(self.model_name.underscore)
							# System permission checked
							if user.has_system_permission(self.model_name.underscore, action)
								current_objects = workspace.send(self.model_name.underscore.pluralize.to_sym)
							# Workspace permission checked
							elsif user.has_system_permission(self.model_name.underscore, action)
								current_objects = workspace.send(self.model_name.underscore.pluralize.to_sym)
							# Category permission checked
							elsif !(cats=workspace.ws_item_categories).blank?
								res = []
								cats.each do |cat|
									if user.has_workspace_permission(workspace.id, 'item_cat_'+cat, action)
										res = res + workspace.send(self.model_name.underscore.pluralize.to_sym)
									end
								end
								current_objects = res
							else
								current_objects = []
							end
					else
						current_objects = []
					end
				else
					if get_sa_config['sa_items'].include?(self.model_name.underscore)
							# System permission checked
							if user.has_system_permission(self.model_name.underscore, action)
								current_objects = self.find(:all)
							# Workspace permission checked
							elsif !(wsl=user.workspaces).blank?
								res = []
								wsl.each do |ws|
									if user.has_workspace_permission(ws.id, self.model_name.underscore, action)
										res = res + ws.send(self.underscore.pluralize.to_sym)
									else
										# lazyness...
										cats = ITEM_CATEGORIES & ws.ws_item_categories.split(',')
										# Check if user can access to, at least, one category of the item in that workspace
										cats.each do |cat|
											if user.has_workspace_permission(ws.id, 'item_cat_'+cat, action)
												res = res + self.find_by_sql("SELECT * FROM #{self.model_name.underscore.pluralize} LEFT JOIN items ON items.itemable='#{self.model_name}' AND items.workspace_id=#{ws.id} WHERE #{self.model_name.underscore.pluralize}.category LIKE #{cat}")
											end
										end
									end
									current_objects = res.uniq
								end
							else
								current_objects = []
							end
					else
						current_objects = []
					end
				end
				return current_objects
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
        return accepting_action(user, 'show')
      end

      # Is user authorized to delete this item?
      def accepts_destroy_for? user
        return accepting_action(user, 'destroy')
      end
      
      # Is user authorized to edit this item?
      def accepts_edit_for? user
        return accepting_action(user, 'edit')
      end
      
      # Is user authorized to create one item?
      def accepts_new_for? user
        return accepting_action(user, 'new')
			end

			def accepts_comment_for?(user)
				return accepting_action(user, 'comment')
			end

			def accepts_rate_for?(user)
				return accepting_action(user, 'rate')
			end

			def accepts_tag_for?(user)
				return accepting_action(user, 'tag')
			end

			private
			def get_sa_config
				if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
					return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
				else
					return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
				end
			end

			def accepting_action(user, action, active=true)
				model_name = self.class.to_s
				# Special stuff
				if !get_sa_config['sa_items'].include?(model_name.underscore) || !active
					return false
				end
        # System access
				if user.has_system_permission(model_name.downcase, action)
					return true
				end
        # Workspace access
				if action=='new'
					wsl = user.workspaces
					# no good, but lazy today
					cats = ITEM_CATEGORIES
				else
					wsl = self.workspaces & user.workspaces
					cats = self.category.split(',')
				end
        wsl.each do |ws|
					# First of all, to check if this workspace accpets these items
					if ws.ws_items.split(',').include?(model_name.underscore)
						# Then with workspace full access
						if user.has_workspace_permission(ws.id, model_name.underscore, action)
							return true
						else
						# And else with the workspace category access
							# restriction with ws item categories
							cats = cats & ws.ws_item_categories.split(',')
							# Check if user can access to, at least, one category of the item in that workspace
							cats.each do |cat|
								if user.has_workspace_permission(ws.id, 'item_cat_'+cat, action)
									return true
								end
							end
						end
					end
				end
				# go away
				false

			end
			
    end
  end
end

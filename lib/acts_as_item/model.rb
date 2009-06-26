# ActsAsItem Specifying Defaut Functanality of the Item(ex: Article, Image, Video...............)
#
# Helps Make Code 'DRY'

module ActsAsItem
  module ModelMethods
		include Configuration

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def item?
        return true if self.respond_to?(:item)
        false
      end
      # ActsAsItem Library for Item Specific Code - Specific Model Methods to All Items
      def acts_as_item
        
        acts_as_rateable

				acts_as_keywordable

				acts_as_commentable

				acts_as_xapian :texts => [:title, :description, :keywords_list]
				
				has_many :items, :as => :itemable, :dependent => :delete_all

				has_many :workspaces, :through => :items

        belongs_to :user

        # Validations
        validates_presence_of	:title, :description, :user

        # Ensure that item is associated to one or more workspaces throught items table
        validates_presence_of :items, :message => "Sélectionner au moins un espace de travail"

				# Retrieve the results matching with Xapian indewes and ordered by weight
				named_scope :full_text_with_xapian,
					lambda { |text| { :conditions => ["#{self.class_name.underscore.pluralize}.id in (?)", ActsAsXapian::Search.new([self.class_name.classify.constantize], text, :limit => 100000).results.sort{ |x, y| x[:weight] <=> y[:weight]}.collect{|x| x[:model].id}] } }

				# Retrieve the results matching the Hash conditions passed
				named_scope :advanced_on_fields,
					lambda { |condition| { :conditions => condition }	}

				named_scope :in_workspaces,
					lambda { |workspace_ids| { :select => "DISTINCT *", :joins => "LEFT JOIN items ON (items.itemable_type = '#{self.class_name}' AND items.workspace_id IN ['1'])" } }

				# Retrieve the results ordered following the paramaters given
				named_scope :filtering_with,
					lambda { |field_name, way, limit|
          if (field_name!='weight')
            { :order => "#{self.class_name.underscore.pluralize}.#{field_name} #{way}", :limit => limit }
          else
            { :limit => limit }
          end
        }

        include ActsAsItem::ModelMethods::InstanceMethods

      end

      # Used for Setting Icon Images for Items
      def icon
        'item_icons/' + self.to_s.underscore + '.png'
      end

      # Other Icon Images for Items
      def icon_48
        'item_icons/' + self.to_s.underscore + '_48.png'
      end

      # Return Label of the Item
			def label
				I18n.t("general.item.#{self.model_name.underscore}")
			end

      # Return Item List for User in Workspace  given the action and filters
			def get_items_list_for_user_with_permission_in_workspace(user, action, workspace, filter_name, filter_way, filter_limit)
				filter_name ||= 'created_at'
				filter_way ||= 'desc'
				# System permission checked
				if user.has_system_permission(self.model_name.underscore, action)
					return workspace.send(self.model_name.underscore.pluralize.to_sym).all(:order => filter_name+' '+filter_way, :limit => filter_limit)
          # Workspace permission checked
				elsif user.has_workspace_permission(workspace.id, self.model_name.underscore, action)
					return workspace.send(self.model_name.underscore.pluralize.to_sym).all(:order => filter_name+' '+filter_way, :limit => filter_limit)
          # Category permission checked
          #				elsif !(cats=workspace.ws_item_categories).blank?
          #					res = []
          #					cats.each do |cat|
          #						if user.has_workspace_permission(workspace.id, 'item_cat_'+cat, action)
          #							res = res + workspace.send(self.model_name.underscore.pluralize.to_sym)
          #						end
          #					end
          #					return res
				else
					return []
				end
			end

      # Return Item List for User given the action and filters
			def get_items_list_for_user_with_permission(user, action, filter_name, filter_way, filter_limit)
				filter_name ||= 'created_at'
				filter_way ||= 'desc'
				# System permission checked
				if user.has_system_permission(self.model_name.underscore, action)
					return self.all(:order => filter_name+' '+filter_way, :limit => filter_limit)
          # Workspace permission checked
          #raise user.workspaces.inspect
				elsif !(wsl=user.workspaces).blank?
					res = []
					# TODO : directly with custom SQL
					wsl.each do |ws|
						if user.has_workspace_permission(ws.id, self.model_name.underscore, action)
							res = res + ws.send(self.model_name.underscore.pluralize.to_sym)
              #						else
              #							# lazyness...
              #							cats = ITEM_CATEGORIES & ws.ws_item_categories.split(',')
              #							# Check if user can access to, at least, one category of the item in that workspace
              #							cats.each do |cat|
              #								if user.has_workspace_permission(ws.id, 'item_cat_'+cat, action)
              #									res = res + self.find_by_sql("SELECT * FROM #{self.model_name.underscore.pluralize} LEFT JOIN items ON items.itemable='#{self.model_name}' AND items.workspace_id=#{ws.id} WHERE #{self.model_name.underscore.pluralize}.category LIKE #{cat}")
              #								end
              #							end
						end
					end
					if filter_way == 'desc'
						res = res.sort{ |x, y| y.send(filter_name.to_sym) <=> x.send(filter_name.to_sym) }
					else
						res = res.sort{ |x, y| x.send(filter_name.to_sym) <=> y.send(filter_name.to_sym) }
					end
					if filter_limit
						res = res[0..filter_limit]
					end
					return res
				else
					return []
				end
			end

			private
			def get_sa_config
				if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
					return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
				else
					return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
				end
			end

    end
    
    module InstanceMethods

      # Return the Workspace Titles ',' seperated
			def workspace_titles
				self.workspaces.map{ |e| e.title }.join(',')
			end

      def icon
        self.class.icon
      end

      # Assign Categoris to Current Items
      def categories_field= params
        self[:category] = params.join(",")
      end

      # Assign Worksapces to current Items ( One Item can be associated with many Worksapces)
      def associated_workspaces= workspace_ids
        self.items = workspace_ids.collect { |id| self.items.build(:workspace_id => id) }
      end
      
      # Check if user authorized to consult this item
      def accepts_show_for? user
        return accepting_action(user, 'show')
      end

      # Check if user authorized to delete this item
      def accepts_destroy_for? user
        return accepting_action(user, 'destroy')
      end
      
      # Check if user authorized to edit this item
      def accepts_edit_for? user
        return accepting_action(user, 'edit')
      end
      
      # Check if user authorized to create one item
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
					cats = get_sa_config['sa_items']
				else
					wsl = self.workspaces & user.workspaces
					#p self.category
					#cats = self.category.to_s.split(',')
				end
        wsl.each do |ws|
					# First of all, to check if this workspace accpets these items
					if ws.ws_items.to_s.split(',').include?(model_name.underscore)
						# Then with workspace full access
						if user.has_workspace_permission(ws.id, model_name.underscore, action)
							return true
              #						else
              #							if cats
              #								# And else with the workspace category access
              #								# restriction with ws item categories
              #								cats = ws.ws_item_categories.to_s.split(',') #& cats
              #								# Check if user can access to, at least, one category of the item in that workspace
              #								cats.each do |cat|
              #									if user.has_workspace_permission(ws.id, 'item_cat_'+cat, action)
              #										return true
              #									end
              #								end
              #							end # if cats
						end
					end # if item available in ws
				end
				# go away
				false

			end
			
    end
  end
end

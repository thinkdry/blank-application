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
				acts_as_taggable

				acts_as_xapian :texts => [:title, :description, :tags],
                 :values => [[:created_at, 0, "created_at", :number],[:title, 1, "title", :string], [:comment_size, 2, "commented", :number], [:rate_average, 3, "rated", :number]]

				has_many :items
				has_many :workspaces, :through => :items
        belongs_to :user
        
        has_many :comments, :as => :commentable, :order => 'created_at ASC'
        
        validates_presence_of	:title, :description, :user
        # Ensure that item is associated to one or more workspaces throught items table
        validates_presence_of :items, :message => "Sélectionner au moins un espace de travail"

				named_scope :full_text,
					lambda { |text| { :conditions => ["#{self.model_name.underscore.pluralize}.id in (?)", ActsAsXapian::Search.new([self.model_name.constantize.classify], text, :limit => 10).results.collect{|x| x[:model].id}] } }

				# Build the mandatory condition checking the fields of that model
				named_scope :advanced_on_fields,
					lambda { |condition| { :conditions => condition }	}

#				named_scope :advanced_on_polymorphic_jointure,
#					lambda { |join_table, join_field, join_model, ids_list|
#						{ :condition => %{
#							SELECT *
#								FROM #{join_table}
#								WHERE
#									#{join_table}.#{join_field}_id = #{self.id} AND
#									#{join_table}.#{join_field}_type = #{self.model_name} AND
#									#{join_table}.#{join_model}_id IN [#{ids_list.split(',')}]
#							}
#						} }

				named_scope :most_viewed,
					lambda { |way, limit| {:order => "#{self.model_name.underscore.pluralize}.viewed_number #{way}", :limit => limit.to_i}}

				named_scope :best_rated,
					lambda { |way, limit| {:order => "#{self.model_name.underscore.pluralize}.rates_average #{way}", :limit => limit.to_i}}

				named_scope :latest,
					lambda { |way, limit| {:order => "#{self.model_name.underscore.pluralize}.created_at #{way}", :limit => limit.to_i}}

				named_scope :alpha_ordered,
					lambda { |way, limit| { :order => "#{self.model_name.underscore.pluralize}.title #{way}", :limit => limit.to_i }}

				named_scope :most_commented,
					lambda { |way, limit| {:order => "#{self.model_name.underscore.pluralize}.comments_number #{way}", :limit => limit.to_i}}

        include ActsAsItem::ModelMethods::InstanceMethods

      end
			
      def icon
        'item_icons/' + self.to_s.underscore + '.png'
      end

			def label
				I18n.t("general.item.#{self.model_name.underscore}")
			end

			def list_items_with_permission_for(user, action, workspace=false)
				if (workspace)
					if workspace.ws_items.include?(self.model_name.underscore)
							# System permission checked
							if user.has_system_permission(self.model_name.underscore, action)
								return workspace.send(self.model_name.underscore.pluralize.to_sym)
							# Workspace permission checked
							elsif user.has_workspace_permission(workspace.id, self.model_name.underscore, action)
								return workspace.send(self.model_name.underscore.pluralize.to_sym)
							# Category permission checked
							elsif !(cats=workspace.ws_item_categories).blank?
								res = []
								cats.each do |cat|
									if user.has_workspace_permission(workspace.id, 'item_cat_'+cat, action)
										res = res + workspace.send(self.model_name.underscore.pluralize.to_sym)
									end
								end
								return res
							else
								p "=========================no perm"
								return []
							end
					else
						p "==========================no type"
						return []
					end
				else
					if get_sa_config['sa_items'].include?(self.model_name.underscore)
							# System permission checked
							if user.has_system_permission(self.model_name.underscore, action)
								return self.find(:all)
							# Workspace permission checked
							elsif !(wsl=user.workspaces).blank?
								res = []
								# TODO : directly with custom SQL
								wsl.each do |ws|
									if user.has_workspace_permission(ws.id, self.model_name.underscore, action)
										res = res + ws.send(self.model_name.underscore.pluralize.to_sym)
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
								end
								return res.sort{ |e1, e2| e2.created_at <=> e1.created_at }.uniq
							else
								return []
							end
					else
						return []
					end
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

      def categories_field= params
        self[:category] = params.join(",")
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

# This module is defining the different methods required by an Object model to acts like an Item.
# It is so defining the mixin method that will include all these required methods inside this Object model.
#
module ActsAsItem
  module ModelMethods

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Mixin adding initialisation and definition of an item model
      #
      # This method initialize a model by mixin of the specified methods.
      #
      # Usage :
      # app/models/article.rb
      #     class Article < ActiveRecord::Base
      #      acts_as_item
      #     end
      def acts_as_item
        # Mixin to add ActsAsRateable methods inside the model
        acts_as_rateable
				# Mixin to add ActsAsKeywordable methods inside the model
				acts_as_keywordable
				# Mixin to add ActsAsCommentable methods inside the model
				acts_as_commentable
				# Method setting the different attribute to index for the Xapian research
				acts_as_xapian :texts => [:title, :description, :keywords_list]
				# Relation N-1 with the 'items' table (Join table)
				has_many :items, :as => :itemable, :dependent => :delete_all
				# Relation N-1 getting the Workspace objects through 'item' table
				has_many :workspaces, :through => :items
				# Relation 1-N with 'users' table
        belongs_to :user
        # Validation of the presence of these fields
        validates_presence_of	:title, :description, :user
        # Valdation of the fact that the item is associated to one or more workspaces throught items table
        validates_presence_of :items, :message => "Sélectionner au moins un espace de travail"
        # Validation of fields not in format of
        validates_not_format_of :title, :description, :with => /(#{SCRIPTING_TAGS})/

				# Retrieve the results matching with Xapian indewes and ordered by weight
				named_scope :full_text_with_xapian,
					lambda { |text| { :conditions => ["#{self.class_name.underscore.pluralize}.id in (?)", ActsAsXapian::Search.new([self.class_name.classify.constantize], text, :limit => 100000).results.sort{ |x, y| x[:weight] <=> y[:weight]}.collect{|x| x[:model].id}] } }

				# Retrieve the results matching the Hash conditions passed
				named_scope :advanced_on_fields,
					lambda { |condition| { :conditions => condition }	}

				# TODO todo
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

				# Inclusion of the instance methods inside the mixin
        include ActsAsItem::ModelMethods::InstanceMethods

      end
      
      # Generally icons are used to enchance visual simplicity to the User.
      #
      # Icon is used to associate every item type with image thumbnail of size 32x32px in default back office view.
      #
      # Usage :
      # <tt>Article.icon</tt>
      # will return "/item_icons/article.png
      def icon
        'item_icons/' + self.to_s.underscore + '.png'
      end

      # Icon_48 is other image to associate every item type with image thumbnail of size 48x48px in default back office view.
      #
      # Usage :
      # <tt>Article.icon_48</tt>
      # will return "/item_icons/article_48.png
      def icon_48
        'item_icons/' + self.to_s.underscore + '_48.png'
      end

      # Label is used to return the name of the item type.
      #
      # Usage :
      # <tt>Image.label</tt>
      # will return "Image"
			def label
				I18n.t("general.item.#{self.model_name.underscore}")
			end

      
			def get_items_list_for_user_with_permission_in_workspace(user, action, workspace, filter_name, filter_way)
				filter_name ||= 'created_at'
				filter_way ||= 'desc'
				# System permission checked or Workspace permission checked
				if user.has_system_permission(self.model_name.underscore, action) || user.has_workspace_permission(workspace.id, self.model_name.underscore, action)
					return workspace.send(self.model_name.underscore.pluralize.to_sym).all(:order => filter_name+' '+filter_way)
				else
					return []
				end
			end

      
			def get_items_list_for_user_with_permission(user, action, filter_name, filter_way)
				filter_name ||= 'created_at'
				filter_way ||= 'desc'
				# System permission checked
				if user.has_system_permission(self.model_name.underscore, action)
					return self.all(:order => filter_name+' '+filter_way)
        else
          return self.find_by_sql("select a.* from #{self.model_name.pluralize.underscore} a,items it,users_workspaces u_s where a.id = it.itemable_id and it.itemable_type = '#{self.model_name}' and it.workspace_id = u_s.workspace_id and u_s.user_id = #{user.id} and u_s.role_id in (select p_s.role_id from permissions_roles p_s where p_s.permission_id in (select p.id from permissions p where p.name = '#{self.model_name.underscore+'_'+action}'))  GROUP BY a.id ORDER BY #{'a.'+filter_name} #{filter_way}")
				end
			end

      # new code
      # List the Items in the Worksapce for the User with permission.
      #
      # Usage :
      # <tt>Article.get_items_list_for_user_with_permission_in_workspace(user_object,'show',workspace_object,'created_at','desc',10)</tt>
      #
      # Will Return the object of type article with defined filters
      #
      # Parameters:
      # - user: Logged in User
      # - action : 'show','new','edit','destroy'
      # - workspace : Workspace of User
      # - filter_name: 'created_at','updated_at','title'..... default: 'created_at'
      # - filter_way: 'asc' or 'desc' default: 'desc'
      # - limit: 'number' default: 10
      def get_paginated_items_list_for_user_with_permission_in_workspace(user, action, workspace, filter_name, filter_way, filter_limit, page)
				filter_name ||= 'created_at'
				filter_way ||= 'desc'
        page ||= 1
				# System permission checked
				if user.has_system_permission(self.model_name.underscore, action) or user.has_workspace_permission(workspace.id, self.model_name.underscore, action)
          return workspace.send(self.model_name.underscore.pluralize.to_sym).paginate(:per_page => filter_limit,:page => page, :order => filter_name+' '+filter_way)
				else
					return []
				end
			end
      
      # will return paginated items
      # List the Items for the User with permission.
      #
      # Usage:
      #
      # <tt>Article.get_items_list_for_user_with_permission(user_object,'show','created_at','desc',10)</tt>
      #
      # Will Return the object of type article with defined filters
      #
      # Parameters :
      # - action : 'show','new','edit','destroy'
      # - filter_name: 'created_at','updated_at','title'..... default: 'created_at'
      # - filter_way: 'asc' or 'desc' default: 'desc'
      # - limit: 'number' default: 10
      def get_paginated_items_list_for_user_with_permission(user, action, filter_name, filter_way, filter_limit, page)
        filter_name ||= 'created_at'
				filter_way ||= 'desc'
        page ||= 1
        # System permission checked
        if user.has_system_permission(self.model_name.underscore, action)
          return self.paginate(:per_page => filter_limit, :page => page ,:order => filter_name+' '+filter_way)
        else
					# TODO : directly with custom SQL
          return self.paginate_by_sql("select a.* from #{self.model_name.pluralize.underscore} a,items it,users_workspaces u_s where a.id = it.itemable_id and it.itemable_type = '#{self.model_name}' and it.workspace_id = u_s.workspace_id and u_s.user_id = #{user.id} and u_s.role_id in (select p_s.role_id from permissions_roles p_s where p_s.permission_id in (select p.id from permissions p where p.name = '#{self.model_name.underscore+'_'+action}'))  GROUP BY a.id ORDER BY #{'a.'+filter_name} #{filter_way}",:per_page => filter_limit,:page => page)
				end
      end
      #

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
      # List Workspace Title's to which the Item is Associated
      #
      # Usage:
      #
      # <tt>article.workspace_titles</tt>
      #
      # will return workspace1, workspace2, workspace3
			def workspace_titles
				self.workspaces.map{ |e| e.title }.join(',')
			end

      # Generally icons are used to enchance visual simplicity to the User.
      #
      # Icon is used to associate every item type with image thumbnail of size 32x32px in default back office view.
      #
      # Usage :
      # <tt>article.icon</tt>
      # will return "/item_icons/article.png
      def icon
        self.class.icon
      end


      # Assign Worksapces to current Item ( One Item can be associated with many Worksapces)
      #
      # Usage :
      # <tt>article.assoicated_workspaces = [workspace1.id, workspace2.id]</tt>
      # will assign workspaces to the item
      def associated_workspaces= workspace_ids
        tmp = workspace_ids
        if self.id
          self.items.each do |i|
            i.delete unless tmp.delete(i.id.to_s)
          end
          tmp.each do |id|
            Item.create(:workspace_id => id,:itemable_id => self.id, :itemable_type => self.class.to_s)
          end
        else
          self.items = workspace_ids.collect { |id| self.items.build(:workspace_id => id) }
        end
      end
      
      # Check User for permission to view the Item
      #
      # Usage:
      #
      # <tt>article.accepts_show_for? user</tt>
      #
      # will return true if the user has permission
      def accepts_show_for? user
        return accepting_action(user, 'show')
      end

      # Check User for permission to Destroy the Item
      #
      # Usage:
      #
      # <tt>article.accepts_destroy_for? user</tt>
      #
      # will return true if the user has permission 
      def accepts_destroy_for? user
        return accepting_action(user, 'destroy')
      end
      
      # Check User for permission to Edit the Item
      #
      # Usage:
      #
      # <tt>article.accepts_edit_for? user</tt>
      #
      # will return true if the user has permission
      def accepts_edit_for? user
        return accepting_action(user, 'edit')
      end
      
      # Check User for permission to Create New Item
      #
      # Usage:
      #
      # <tt>article.accepts_new_for? user</tt>
      #
      # will return true if the user has permission 
      def accepts_new_for? user
        return accepting_action(user, 'new')
			end

      # Check User for permission to Add Comment to Item
      #
      # Usage:
      #
      # <tt>article.accepts_comment_for?(user)</tt>
      #
      # will return true if the user has permission
			def accepts_comment_for?(user)
				return accepting_action(user, 'comment')
			end

      # Check User for permission to Add Rating to Item
      #
      # Usage:
      #
      # <tt>article.accepts_rate_for?(user)</tt>
      #
      # will return true if the user has permission
			def accepts_rate_for?(user)
				return accepting_action(user, 'rate')
			end

      # Check User for permission to Add Tag to Item
      #
      # Usage:
      #
      # <tt>article.accepts_tag_for?(user)</tt>
      #
      # will return true if the user has permission
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
						end
					end # if item available in ws
				end
				# go away
				false

			end
			
    end
  end
end

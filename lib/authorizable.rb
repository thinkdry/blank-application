module Authorizable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			def acts_as_authorizable(hash, tab)
				skip_before_filter :is_logged?, :only => tab
				before_filter :permission_checking
				define_method :permission_checking do
					if hash[params[:action]]
						obj = params[:controller].classify.constantize
						@current_object = ['new', 'create','validate'].include?(params[:action]) ? obj.new : obj.find(params[:id])
						#no_permission_redirection unless @current_user && @current_object.send("accepts_#{hash[params[:action]]}_for?".to_sym, @current_user)
						no_permission_redirection unless @current_user && @current_object.has_permission_for?(hash[params[:action]], @current_user)
					else
						# it is permissive
					end
				end
				include Authorizable::ControllerMethods::InstanceMethods
      end
    end
    
    module InstanceMethods
    end
		
  end
end

module Authorizable
  module ModelMethods

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_authorizable
				include Authorizable::ModelMethods::InstanceMethods
				if ITEMS.include?(self.to_s.underscore)
					include Authorizable::ModelMethods::IMItem
				elsif ['workspace'].include?(self.to_s.underscore)
					include Authorizable::ModelMethods::IMWorkspace
				elsif self.to_s.underscore == 'user'
					include Authorizable::ModelMethods::IMUser
				end
			end
    end

    module InstanceMethods
			def has_permission_for?(permission, user)
				return accepting_action(user, permission)
			end
		end
		
		module IMUser
				def accepting_action(user, action, spe_cond=false, sys_cond=false, ws_cond=true)
					# Special access
					if user.has_system_role('superadmin') || (user=self.id && ['show', 'edit'].include?(action)) || spe_cond
						return true
					end
					# System access
					if user.has_system_permission(self.class.to_s.downcase, action) || sys_cond
						return true
					end
					# Workspace access
					# The only permission linked to an user in a workspace is 'show'
					if action=='show'
						self.workspaces.each do |ws|
							if ws.users.include?(user)
								if user.has_workspace_permission(ws.id, self.class.to_s.downcase, action) && ws_cond
									return true
								end
							end
						end
					end
					false
				end
		end

		module IMWorkspace
			def accepting_action(user, action, spe_cond=false, sys_cond=false, ws_cond=true)
				# Special access
				if user.has_system_role('superadmin') || spe_cond
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

		module IMItem
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

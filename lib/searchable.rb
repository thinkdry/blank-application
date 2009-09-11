module Searchable
  module ModelMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			def acts_as_searchable(*args)
				options = args.extract_options!
				
				if options[:full_text_fields]
					acts_as_xapian :texts => options[:full_text_fields]
					# Retrieve the results matching with Xapian indewes and ordered by weight
					named_scope :searching_text_with_xapian,
						lambda { |text| { :conditions => ["#{self.class_name.underscore.pluralize}.id in (?)", ActsAsXapian::Search.new([self.class_name.classify.constantize], text, :limit => 100000).results.sort{ |x, y| x[:weight] <=> y[:weight]}.collect{|x| x[:model].id}] }
					}
				end
				
				
#				# Retrieve the results matching the Hash conditions passed
#				named_scope :advanced_on_fields,
#					lambda { |condition| { :conditions => condition.delete_if{ |k, e| !condition_fields_tabs.include?(k.to_s) } }	}

#				# TODO todo
#				named_scope :in_workspaces,
#					lambda { |workspace_ids| { :select => "DISTINCT *", :joins => "LEFT JOIN items_workspaces ON (items_workspaces.itemable_type = '#{self.class_name}' AND items_workspaces.workspace_id IN ['1'])" } }

				# Retrieve the results ordered following the paramaters given
				named_scope :filtering_on,
					lambda { |field_name, way|
          if (field_name!='weight')
            { :order => "#{self.class_name.underscore.pluralize}.#{field_name} #{way}" }
          else
            { :limit => limit, :offset => offset }
          end
        }

				named_scope :paginating_with,
					lambda { |limit, offset| { :limit => limit, :offset => offset }
				}

				def get_da_objects_list(*args)
					options = args.extract_options!
					req = self
					req = req.searching_text_with_xapian(options[:text]) if options[:text]
					req = req.matching_user_with_permission_in_workspaces(options[:user_id], 'show', options[:workspace_ids])

					#req = req.filtering_on(options[:filter][:field], options[:filter][:way])
					#req = req.paginating_with(options[:pagination][:per_page].to_i, ((options[:pagination][:page].to_i - 1) * options[:pagination][:per_page].to_i))
					req = req.paginate(:per_page => options[:pagination][:per_page].to_i, :page => options[:pagination][:page].to_i, :order => options[:filter][:field]+' '+options[:filter][:way])
				end

				include Searchable::ModelMethods::InstanceMethods
      end

    end
    
    module InstanceMethods
      
    end
  end
end
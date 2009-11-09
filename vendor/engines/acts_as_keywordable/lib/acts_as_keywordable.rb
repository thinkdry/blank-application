# This module is defining the mixin methods allowing an object to get and manage keywords.
#
module ActsAsKeywordable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			# Mixin method used for the controller
      def acts_as_keywordable
#				before_save do
#					params[@current_object.class.to_s.underscore][:keywords_field] ||= []
#				end
				# Inclusion of the instance methods inside the mixin
        include ActsAsKeywordable::ControllerMethods::InstanceMethods
			end
    end
    
    module InstanceMethods

    end

	end

	module ModelMethods

		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			# Mixin method used for the model
			def acts_as_keywordable
				# Relation N-1 to the 'keywordings' table (Join table)
				has_many :keywordings, :as => :keywordable, :dependent => :delete_all
				# Relation N-N with the 'keywords' table through the 'keywordings' one
				has_many :keywords, :through => :keywordings
				# Scope allowing to get the object linked to a specific keyword (not really well implemented)
				named_scope :matching_with_keyword,
					lambda { |keyword_id| 
					{ :joins => "LEFT JOIN keywordings ON (keywordings.keywordable_type = '#{self.class_name}' "+
							"AND keywordings.keywordable_id = #{self.class_name.underscore.pluralize}.id) "+
							"WHERE keywordings.keyword_id = #{keyword_id}" } }
				# Inclusion of the instance methods inside the mixin
				include ActsAsKeywordable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods
			# Method returning the list of the keywords as a string with ',' as separator
			def keywords_list
				if self.keywords.size > 0
					return self.keywords.collect { |t| t.name }.join(', ')
				else
					return []
				end
			end

			# Method setting the keywords for an object
			#
			# This method will check the list passed as parameter, check the keywords which are already saved,
			# and on the same time delete the ones which are not anymore linked to the current object.
			# After, it will create the new Keyword object and the Keywording ones.
			def keywords_field= params
				tmp = params.uniq
				self.keywordings.each do |k|
					self.keywords.delete(k.keyword) unless tmp.delete(k.keyword.name)
				end
				tmp.each do |keyword_name|
					keyword = Keyword.find(:first, :conditions => { :name => keyword_name }) || Keyword.new(:name => keyword_name)
					self.keywordings.build(:keyword => keyword)
				end
			end

		end

  end
end
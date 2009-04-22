module ActsAsKeywordable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_keywordable
#				before_save do
#					params[@current_object.class.to_s.underscore][:keywords_field] ||= []
#				end
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
			def acts_as_keywordable
				has_many :keywordings, :as => :keywordable, :dependent => :destroy
				has_many :keywords, :through => :keywordings
				# Scope allowing to get the object linked to a specific keyword (not really well implemented
				named_scope :matching_with_keyword,
					lambda { |keyword_id| 
					{ :joins => "LEFT JOIN keywordings ON (keywordings.keywordable_type = '#{self.class_name}' "+
							"AND keywordings.keywordable_id = #{self.class_name.underscore.pluralize}.id) "+
							"WHERE keywordings.keyword_id = #{keyword_id}" } }
				include ActsAsKeywordable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods

			def keywords_list
				if self.keywords.size > 0
					return self.keywords.collect { |t| t.name }.join(', ')
				else
					return []
				end
			end

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
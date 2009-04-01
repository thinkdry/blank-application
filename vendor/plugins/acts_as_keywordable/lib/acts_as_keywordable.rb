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
				has_many :keywordings, :as => :keywordable
				has_many :keywords, :through => :keywordings
				include ActsAsKeywordable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods

			def keywords_list
				if self.keywords.size > 0
					return self.keywords.collect { |t| t.name }.join(', ')
				else
					return I18n.t('general.common_word.none') || 'none'
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
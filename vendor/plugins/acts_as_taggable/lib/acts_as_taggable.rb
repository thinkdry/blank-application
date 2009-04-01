module ActsAsTaggable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_taggable
				before :create, :update do
					params[@current_object.class.to_s.underscore][:keywords_field] ||= []
				end
        include ActsAsTaggable::ControllerMethods::InstanceMethods
			end
    end
    
    module InstanceMethods
			def add_tag
				tag_name = params[:tag][:name]
        tag = Tag.find_by_name(tag_name) || Tag.create(:name => tag_name, :user_id => @current_user.id)
        current_object.taggings.create(:tag => tag)
        render :update do |page|
          page.insert_html :bottom, 'tags_list', ' ' + item_tag(tag)
        end
			end

			def remove_tag
				tag = current_object.taggings.find(:first, :conditions => { :tag_id => params[:tag_id].to_i })
        tag_dom_id = "tag_#{tag.tag_id}"
        tag.destroy
        render :update do |page|
          page.remove tag_dom_id
        end
			end
    end

	end

	module ModelMethods

		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			def acts_as_taggable
				has_many :taggings, :as => :taggable
				has_many :tags, :through => :taggings
				include ActsAsTaggable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods

			def tags_list
				if self.tags.size > 0
					return self.tags.collect { |t| t.name }.join(', ')
				else
					return I18n.t('general.common_word.none') || 'none'
				end
			end

#			def tags_field= params
#				tmp = params.uniq
#				self.taggings.each do |tagging|
#					self.tags.delete(tagging.tag) unless tmp.delete(tagging.tag.name)
#				end
#				tmp.each do |tag_name|
#					tag = Tag.find(:first, :conditions => { :name => tag_name }) || Tag.new(:name => tag_name)
#					self.taggings.build(:tag => tag)
#				end
#			end

		end

  end
end
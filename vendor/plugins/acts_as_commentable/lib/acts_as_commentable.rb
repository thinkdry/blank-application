module ActsAsCommentable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_commentable
        include ActsAsCommentable::ControllerMethods::InstanceMethods
			end
    end
    
    module InstanceMethods
      def comment
        comment = current_object.comments.create(params[:comment].merge(:user => @current_user))
				current_object.comments_number = current_object.comments_number.to_i + 1
				current_object.save
        render :update do |page|
          page.insert_html :bottom, 'comment_list', :partial => "items/comment", :object => comment
        end
      end

			def change_state(new_state)
				
			end
     
    end
  end
end
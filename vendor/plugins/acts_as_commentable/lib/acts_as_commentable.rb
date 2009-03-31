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
        if yacaph_validated?
          comment = current_object.comments.create(params[:comment].merge(:user => @current_user))
          current_object.comments_number = current_object.comments_number.to_i + 1
          current_object.save
          render :update do |page|
            page.insert_html :bottom, 'comment_list', :partial => "items/comment", :object => comment
            page.replace_html 'captcha',  :partial => "items/captcha"
          end
        else
          render :update do |page|
            page.replace_html 'captcha',  :partial => "items/captcha"
          end
        end
      end
     
    end
  end
end
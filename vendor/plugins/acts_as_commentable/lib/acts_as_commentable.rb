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
      def add_comment
        if logged_in?
          current_object.comments.create(params[:comment].merge(:user => @current_user))
          current_object.comments_number = current_object.comments_number.to_i + 1
          current_object.save
          render :update do |page|
            page.replace_html "ajax_info", :text =>"Votre message est enregistré, nous vous remercions de votre participation"
          end
        else
          if yacaph_validated?
            current_object.comments.create(params[:comment])
            current_object.comments_number = current_object.comments_number.to_i + 1
            current_object.save
            render :update do |page|
              page.replace_html "ajax_info", :text =>"Votre message est enregistré, nous vous remercions de votre participation"
              page.replace_html "comment_captcha",  :partial => "items/captcha"
            end
          else
            render :update do |page|
              page.replace_html "ajax_info", :text => "Le code de vérification est incorrect"
              page.replace_html "comment_captcha",  :partial => "items/captcha"
            end
          end
        end
			end

			def update_comment(new_state)
				
			end
     
    end
  end

	module ModelMethods

		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			def acts_as_commentable
				has_many :comments, :as => :commentable, :order => 'created_at ASC'
				include ActsAsTaggable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods

		end

	end



end
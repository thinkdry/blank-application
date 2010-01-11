# This module is defining the mixin methods allowing an object to get and manage comments.
#
module ActsAsCommentable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			# Mixin method used for the controller
      def acts_as_commentable
				# Inclusion of the instance methods inside the mixin
        include ActsAsCommentable::ControllerMethods::InstanceMethods
			end
    end
    
    module InstanceMethods
			# Action to add a comment to the object
      def add_comment
        @comment = current_object.comments.create(params[:comment].merge(:user => @current_user, :state => DEFAULT_COMMENT_STATE))
        current_object.update_attributes(:comments_number => current_object.comments_number.to_i + 1)
        @current_object = current_object
        flash[:notice] = 'Comment was successfully Added.'
        respond_to do |format|
    	    format.js {render :template => "comments/add_comment.js.erb", :layout => false}
    	  end
      	
        # if logged_in?  
        #         else
        #           #not loggeud => captcha validation.
        #           if yacaph_validated?
        #             current_object.comments.create(params[:comment])
        #             current_object.update_attributes(:comments_number => current_object.comments_number.to_i + 1)
        #             render :update do |page|
        #               page.show 'notice'
        #               page.replace_html "notice", :text => I18n.t('comment.add_comment.ajax_message_comment_submited')
        #               page.replace_html "comment_captcha",  :partial => "items/captcha"
        #             end
        #           else
        #             render :update do |page|
        #               page.show 'error'
        #               page.replace_html "error", :text => I18n.t('general.common_word.ajax_message_captcha_invalid')
        #               page.replace_html "comment_captcha",  :partial => "items/captcha"
        #             end
        #           end
        #         end
			end
    end
  end

	module ModelMethods

		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			# Mixin method used for the model
			def acts_as_commentable
				# Relation N-1 to the 'comments' table to get ALL the comments
				has_many :all_comments, :class_name => 'Comment', :as => :commentable, :dependent => :delete_all
				# Relation N-1 to the 'comments' table to get the VALIDATED comments
				has_many :comments, :as => :commentable, :order => 'created_at ASC', :conditions => { :state => 'validated', :parent_id => nil}
				# Inclusion of the instance methods inside the mixin
				include ActsAsCommentable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods

		end

	end



end

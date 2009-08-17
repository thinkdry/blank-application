# This controller is managing the different actions relative to the Newsletter item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class NewslettersController < ApplicationController

	

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do
		# After the creation, redirection to the edition in order to be able to set the body
    response_for :create do |format|
			format.html { redirect_to edit_item_path(@current_object) }
			format.xml { render :xml => @current_object }
			format.json { render :json => @current_object }
		end
  end

  # Filter skipping the 'is_logged?' filter to allow non-logged user to unsubscribe from the newsletter
	skip_before_filter :is_logged?, :only => [:unsubscribe]

  # Action sending the newsletter to a selected group
  #
	# This function s creating the QueuedMail objects that are defining the different newsletter
	# to be sent to the members of the specified group (found with 'group_id parameter).
	# It is redirecting on the newsletter show page.
	#
  # Usage URL:
  # - newsletters/1/send_to_a_group
  # - workspaces/1/newsletters/1/send_to_a_group
  def send_to_a_group
    @group = Group.find(params[:group_id])
    @newsletter = Newsletter.find(params[:newsletter_id])
    if GroupsNewsletter.new(:group_id => @group.id,:newsletter_id => @newsletter.id,:sent_on=>Time.now).save
      for member in @group.members
        if member.newsletter
          args = [member.email,member.model_name,@newsletter.from_email,@newsletter.subject, @newsletter.description, @newsletter.body]
          QueuedMail.add("UserMailer","send_newsletter", args, 0)
        end
      end
      #MiddleMan.worker(:cronjob_worker).async_newthread
      redirect_to (current_workspace ? workspace_path(current_workspace.id)+newsletter_path(@newsletter) : newsletter_path(@newsletter))
    end
  end

  # Method to unsubscribe from a newsletter for given email address
  #
	# TODO bl i
	#
  # Usage URL:
  # 
  # /unsubscribe_for_newsletter?member_type=people&email=abc@abc.com
  #
  def unsubscribe
    @member = params[:member_type].classify.constantize.find_by_email(params[:email])
    if @member.update_attribute(:newsletter, false)
      flash.now[:notice] = I18n.t('newsletter.unsubscribe.flash_notice')
    else
      flash.now[:error] = "Unable to unsubscribe. Please try again."
    end
    redirect_to @configuration['sa_application_url']
  end
end

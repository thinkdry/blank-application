# This controller is managing the different actions relative to the Newsletter item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::NewslettersController < Admin::ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do

    before :show do
			# Set the group available for newsletter sending
      if current_workspace
        @groups = current_workspace.groups.all(:select =>"id, title")
      else
        @groups = @current_object.workspaces.map{|w| w.groups.all(:select =>"id, title")}.flatten!
      end
      
    end
		# After the creation, redirection to the edition in order to be able to set the body
    response_for :create do |format|
			format.html { redirect_to edit_item_path(@current_object) }
			format.xml { render :xml => @current_object }
			format.json { render :json => @current_object }
		end
  end

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
      for member in @group.contacts_workspaces
        if member.state == 'subscribed' or member.state.to_s.blank?
          args = [member.to_group_member['email'],member.sha1_id,@newsletter.from_email,
							@newsletter.subject, @newsletter.description, @newsletter.body]
          QueuedMail.add("UserMailer","send_newsletter", args, 0)
        end
      end
      flash[:notice] = I18n.t('newsletter.send_newsletter.queued_newsletter_flash_notice') 
			Delayed::Job.enqueue(NewsletterJob.new)
		else
			flash[:error] = I18n.t('newsletter.send_newsletter.queued_newsletter_flash_error')
		end
		redirect_to(current_workspace ? workspace_path(current_workspace.id)+newsletter_path(@newsletter) : newsletter_path(@newsletter))
  end

end

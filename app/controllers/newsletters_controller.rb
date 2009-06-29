class NewslettersController < ApplicationController

  acts_as_ajax_validation
  acts_as_item do
    response_for :create do |format|
			format.html { redirect_to edit_item_path(@current_object) }
			format.xml { render :xml => @current_object }
			format.json { render :json => @current_object }
		end
  end
  skip_before_filter :is_logged?, :only => ['unsubscribe']

  # Method to Send Newsletter to Selected Group
  def send_newsletter
    @group = Group.find(params[:group_id])
    @newsletter = Newsletter.find(params[:newsletter_id])
    if GroupsNewsletter.new(:group_id => @group.id,:newsletter_id => @newsletter.id,:sent_on=>Time.now).save
      for member in @group.members
        if member.newsletter
          args = [member.email,member.class.to_s.downcase,@newsletter.from_email,@newsletter.subject, @newsletter.description, @newsletter.body]
          QueuedMail.add("UserMailer","send_newsletter", args, 0)
        end
      end
      MiddleMan.worker(:cronjob_worker).async_newthread
      redirect_to newsletter_path(@newsletter)
    end
  end

  # Method to Unsubscribe from a newsletter for given E-Mail 
  def unsubscribe
    @member = params[:member_type].classify.constantize.find_by_email(params[:email])
    if @member.update_attributes(:newsletter => false)
      flash[:notice] = I18n.t('newsletter.unsubscribe.flash_notice')
      redirect_to @configuration['sa_application_url']
    end
  end
end

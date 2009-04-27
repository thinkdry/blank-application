class NewslettersController < ApplicationController

  acts_as_ajax_validation
  acts_as_item
  skip_before_filter :is_logged?, :only => ['unsubscribe']
  def send_newsletter
    @group = Group.find(params[:group_id])
    @newsletter = Newsletter.find(params[:newsletter_id])
    
    if GroupsNewsletter.new(:group_id => @group.id,:newsletter_id => @newsletter.id,:sent_on=>Time.now).save
      for member in @group.members
        if member.newsletter
         args = [member.email,member.class.to_s.downcase,@configuration['sa_contact_email'],@newsletter.title, @newsletter.description, @newsletter.body]
         QueuedMail.add("UserMailer","send_newsletter", args, 0)
        end
      end
      redirect_to newsletter_path(@newsletter)
    end
  end

  def unsubscribe
    @member = params[:member_type].classify.constantize.find_by_email(params[:email])
    if @member.update_attributes(:newsletter => false)
      flash[:notice] = I18n.t('newsletter.unsubscribe.flash_notice')
      redirect_to @configuration['sa_application_url']
    end
  end
end

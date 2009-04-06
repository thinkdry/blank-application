class NewslettersController < ApplicationController

  acts_as_ajax_validation
  acts_as_item

  def send_newsletter
    @group = Group.find(params[:group_id])
    @newsletter = Newsletter.find(params[:newsletter_id])
    
    if GroupsNewsletter.new(:group_id => @group.id,:newsletter_id => @newsletter.id,:sent_on=>Time.now).save
      for person in @group.people
        UserMailer.deliver_send_newsletter(@newsletter,person)
      end
      redirect_to newsletter_path(@newsletter)
    end
  end
end

class NewslettersController < ApplicationController

  acts_as_ajax_validation
  acts_as_item

  def send_newsletter
    @group = Group.find(params[:group_id])
    @newsletter = Newsletter.find(params[:newsletter_id])
    
    if GroupsNewsletter.new(:group_id => @group.id,:newsletter_id => @newsletter.id,:sent_on=>Time.now).save
      for person in @group.people
#        NewsletterMailer.deliver_send_newsletter(@newsletter,person)
#        Email.new(:from=>get_sa_config['sa_contact_email'],:to=>person.email,:mail=>@newsletter.body,:subject=>"Newsletter - "+@newsletter.title, :created_on=>Time.now).save
         args = [person.email,"contact@thinkdry.com",@newsletter.title, @newsletter.description, @newsletter.body]
         QueuedMail.add("UserMailer","send_newsletter", args, 0)
        
      end
      redirect_to newsletter_path(@newsletter)
    end
  end
end

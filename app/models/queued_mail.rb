# == Schema Information
# Schema version: 20181126085723
#
# Table name: queued_mails
#
#  id            :integer(4)      not null, primary key
#  mailer        :string(255)
#  mailer_method :string(255)
#  args          :text
#  priority      :integer(4)      default(0)
#  created_at    :datetime
#

# require 'user_mailer'

class QueuedMail < ActiveRecord::Base
  serialize :args

  # Send 20 Mail with Priority Descending, destroy after sending
  def self.send_email
    find(:all, :order=> "priority desc, id desc", :limit=>20).each do |mail|
      mailer_class = mail.mailer.constantize
      mailer_method = ("deliver_" + mail.mailer_method).to_sym
      mailer_class.send(mailer_method, *mail.args)
      mail.destroy
    end
    true
  end

  # Add a Mail to the Queue
  def self.add(mailer, method, args, priority)
    QueuedMail.create(:mailer=>mailer.to_s, :mailer_method=>method.to_s, :args => args, :priority=> priority)
  end
end  

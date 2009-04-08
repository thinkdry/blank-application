# require 'user_mailer'
 class QueuedMail < ActiveRecord::Base
     serialize :args

     def self.send_email
       find(:all, :order=> "priority desc, id desc", :limit=>20).each do |mail|
         mailer_class = mail.mailer.constantize
         mailer_method = ("deliver_" + mail.mailer_method).to_sym
         mailer_class.send(mailer_method, *mail.args)
         mail.destroy
       end
       true
     end

     def self.add(mailer, method, args, priority)
       QueuedMail.create(:mailer=>mailer.to_s, :mailer_method=>method.to_s, :args => args, :priority=> priority)
     end
 end  
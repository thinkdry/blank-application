#class Audit < ActiveRecord::Base
  
  #
  # when the action is update it returns field status 
  #
 # def audit_action
 #   if self.action == 'update'
 #     if self.changes["status"]
 #       self.changes["status"][1]
 #     else
 #       self.action
 #     end
 #   else
 #     self.action
 #   end
 # end

#end

class AuditObserver < ActiveRecord::Observer

  observe Audit

   def after_create(audit)   
      if RAILS_ENV == 'production'
        model_id = NotificationFilter.models.find_by_name(audit.auditable_type.downcase).id
        action_id = NotificationFilter.actions.find_by_name(audit.action).id

        subscribers = User.subscribers_of(model_id,action_id)      
        for subscriber in subscribers
          args = [subscriber.email,subscriber.class.to_s.downcase,'vincent@thinkdry.com','Evolution du back office', audit.id,subscriber.id]
          QueuedMail.add("UserMailer","send_back_office_updates", args, 1)
        end
      end
   end
end

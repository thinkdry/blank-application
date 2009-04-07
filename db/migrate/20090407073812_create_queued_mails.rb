class CreateQueuedMails < ActiveRecord::Migration
   def self.up
     create_table :queued_mails do |t|
       t.column :mailer , :string
       t.column :mailer_method, :string
       t.column :args, :text
       t.column :priority, :integer, :default=> 0
       t.datetime :created_at
     end
   end

   def self.down
     drop_table :queued_mails
   end   
end

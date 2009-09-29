class CreateQueuedMailsTable < ActiveRecord::Migration

  def self.up
    create_table :queued_mails do |t|
       t.string  :mailer
       t.string  :mailer_method
       t.text    :args
       t.integer :priority, :default=> 0
       t.datetime :created_at
     end
  end

  def self.down
    drop_table :queued_mails
  end
end


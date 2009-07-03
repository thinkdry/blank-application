class AddUserIdToQueuedMail < ActiveRecord::Migration
  def self.up
    add_column :queued_mails, :user_id, :integer
  end

  def self.down
    remove_column :queued_mails, :user_id
  end
end

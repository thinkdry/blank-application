class AddUrlToQueuedMail < ActiveRecord::Migration
  def self.up
    add_column :queued_mails, :url, :string
  end

  def self.down
    remove_column :queued_mails, :url
  end
end

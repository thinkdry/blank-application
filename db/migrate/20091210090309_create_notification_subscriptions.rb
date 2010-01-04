class CreateNotificationSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :notification_subscriptions do |t|
      t.references :user
      t.references :notification_filter
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_subscriptions
  end
end

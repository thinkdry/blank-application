class CreateNotificationFilters < ActiveRecord::Migration
  def self.up
    create_table :notification_filters do |t|
      t.string :name
      t.string :group
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_filters
  end
end

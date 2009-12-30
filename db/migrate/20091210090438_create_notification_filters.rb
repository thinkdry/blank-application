class CreateNotificationFilters < ActiveRecord::Migration
  def self.up
    create_table :notification_filters do |t|
      t.string :name
      t.string :group
      t.timestamps
    end
		ITEMS.each do |item|
			NotificationFilter.create(:name => item, :group => 'model')
		end

		NotificationFilter.create(:name => 'destroy', :group => 'action')
		NotificationFilter.create(:name => 'create', :group => '')
		NotificationFilter.create(:name => 'update', :group => '')

  end

  def self.down
    drop_table :notification_filters
  end
end

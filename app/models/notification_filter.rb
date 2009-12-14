class NotificationFilter < ActiveRecord::Base

  has_many :notification_subscriptions, :dependent => :destroy
  has_many :users, :through => :notification_subscriptions

  named_scope :models, :conditions => { :group => 'model'}
  named_scope :actions, :conditions => { :group => 'action'}

end

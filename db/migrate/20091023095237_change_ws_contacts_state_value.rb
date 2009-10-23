class ChangeWsContactsStateValue < ActiveRecord::Migration
  def self.up
    ContactsWorkspace.all.each do |c|
      if c.state.nil?
        c.update_attributes(:state => 'subscribed')
      end
    end
  end

  def self.down
  end
end

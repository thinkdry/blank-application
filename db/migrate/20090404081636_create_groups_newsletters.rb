class CreateGroupsNewsletters < ActiveRecord::Migration
  def self.up
    create_table :groups_newsletters do |t|
      t.integer :newsletter_id
      t.integer :group_id
      t.datetime :sent_on
#      t.timestamps
    end
  end

  def self.down
    drop_table :groups_newsletters
  end
end

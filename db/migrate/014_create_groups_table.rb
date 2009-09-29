class CreateGroupsTable < ActiveRecord::Migration

  def self.up
    create_table :groups do |t|
			t.integer :user_id
      t.string  :title, :limit => 255
      t.text    :description
      t.string  :state, :limit => 15
      t.integer :workspace_id
      t.integer :comments_number, :default => 0
			t.timestamps
    end
    add_index :groups, :user_id
    add_index :groups, :workspace_id

    create_table :groupings, :id => false do |t|
      t.integer :group_id
      t.integer :groupable_id
      t.string  :groupable_type
      t.integer :user_id
      t.integer :contacts_workspace_id
      t.timestamps
    end
    add_index :groupings, :group_id
    add_index :groupings, :groupable_id
    add_index :groupings, :groupable_type
    add_index :groupings, :user_id
    add_index :groupings, :contacts_workspace_id

    create_table :groups_newsletters do |t|
      t.integer  :newsletter_id
      t.integer  :group_id
      t.datetime :sent_on
    end
    add_index :groups_newsletters, :newsletter_id
    add_index :groups_newsletters, :group_id
  end

  def self.down
    drop_table :groups
    drop_table :groupings
    drop_table :groups_newsletters
  end
end


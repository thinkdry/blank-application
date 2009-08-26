class AddSha1IdToContactsWorkspaces < ActiveRecord::Migration
  def self.up
    add_column :contacts_workspaces, :sha1_id, :string
  end

  def self.down
    remove_column :contacts_workspaces, :sha1_id
  end
end

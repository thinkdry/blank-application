# == Schema Information
# Schema version: 20181126085723
#
# Table name: workspaces
#
#  id                 :integer(4)      not null, primary key
#  creator_id         :integer(4)
#  description        :text
#  title              :string(255)
#  state              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  ws_items           :string(255)     default("")
#  ws_item_categories :string(255)     default("")
#  logo_file_name     :string(255)
#  logo_content_type  :string(255)
#  logo_file_size     :integer(4)
#  ws_available_types :string(255)     default("")
#

# This object deals with the link between users and items.
# Actually, an item is linked to a workspace (through the 'items' table)
# and an user too (through the 'users_workspaces' table, with a specific role).
#
class Workspace < ActiveRecord::Base

	acts_as_container

  has_many :contacts_workspaces,:dependent => :destroy

  has_many :groups, :dependent => :delete_all

  has_many  :people,
    :through      => :contacts_workspaces,
    :source       => :contactable,
    :source_type  => "Person",
    :foreign_key => "contactable_id",
    :conditions   => "contacts_workspaces.contactable_type = 'Person'",
    :order => "people.email ASC"

	# Mixin method alloing to make easy search on the model
	acts_as_searchable :full_text_fields => [:title, :description],
    :conditionnal_attribute => []


  # will save contacts in contacts_workpsaces table and contact_ids = "Person_1,Person_2"
  def selected_contacts= contact_ids
    tmp = contact_ids.split(',') || []
    self.contacts_workspaces.each do |k|
      k.destroy unless tmp.delete(k.contactable_type+'_'+k.contactable_id.to_s)
    end
    tmp.each do |contact|
      if !ContactsWorkspace.exists?(:workspace_id => self.id, :contactable_id => contact.split('_')[1], :contactable_type => contact.split('_')[0])
        self.contacts_workspaces << contacts_workspaces.build(:workspace_id => self.id, :contactable_id => contact.split('_')[1], :contactable_type => contact.split('_')[0])
      end
    end
  end

end

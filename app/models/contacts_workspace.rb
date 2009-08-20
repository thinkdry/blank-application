class ContactsWorkspace < ActiveRecord::Base

	# Relation N-1 with the 'groupings' table
	has_many :groupings, :dependent => :delete_all
  # Relation 1-N with the 'workspaces' table
  belongs_to :workspace#, :dependent => :delete_all
	# Polymorphic relation with the items tables
  belongs_to :contactable, :polymorphic => true

#	named_scope :not_being_in_one_group_in_workspace, lambda{ |workspace_id|
#		{ :joins => "LEFT JOIN groupings ON groupings.contacts_workspace_id = contacts_workspaces.id"+
#				"LEFT JOIN groups ON group",
#			:conditions => {  } }
#	}

	def to_group_member(user_id=nil)
		return {
				'id' => self.id,
				'state' => self.state,
				'contact_id' => self.contactable_id,
				'contact_type' => self.contactable_type,
				'email' => begin self.contactable.email rescue self.contactable.from_email end,
				'first_name' => begin self.contactable.first_name rescue self.contactable.firstname end,
				'last_name' => begin self.contactable.last_name rescue self.contactable.lastname end,
				'created_at' => self.created_at,
				'permission' => false || (user_id && self.contactable_type=='Person' && self.contactable.user_id==user_id)
			}
	end

end

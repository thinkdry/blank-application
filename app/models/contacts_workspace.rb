require 'digest/sha1'

# This object is used to manage the contacts of a workspace.
# It is used to build groups in that workspaces.
class ContactsWorkspace < ActiveRecord::Base

	# Relation N-1 with the 'groupings' table
	has_many :groupings, :dependent => :delete_all
  # Relation 1-N with the 'workspaces' table
  belongs_to :workspace#, :dependent => :delete_all
	# Polymorphic relation with the items tables
  belongs_to :contactable, :polymorphic => true
	# Filter updating the 'sha_id' field used for unsubscribe
  before_save :create_sha1_id

	# Method returning a generic structure cutting specific part due to polymorphism
	def to_group_member(user_id=nil)
		return {
				'id' => self.id,
				'state' => (self.state.nil? or self.state.blank?) ? I18n.t('general.common_word.subscribed') : I18n.t('general.common_word.'+self.state),
				'contact_id' => self.contactable_id,
				'contact_type' => self.contactable_type,
				'email' => begin self.contactable.email rescue self.contactable.from_email end,
				'first_name' => begin self.contactable.first_name rescue self.contactable.firstname end,
				'last_name' => begin self.contactable.last_name rescue self.contactable.lastname end,
				'created_at' => self.created_at,
				'permission' => false || (user_id && self.contactable_type=='Person' && self.contactable.user_id==user_id)
			}
	end

  private
	# Method updating the 'sha1_id' field
  def create_sha1_id
    self.sha1_id = Digest::SHA1.hexdigest("#{self.id}-#{self.contactable_type}-#{self.contactable_id}")
  end
end

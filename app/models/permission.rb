# == Schema Information
# Schema version: 20181126085723
#
# Table name: permissions
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#  type_permission :string(255)
#

# This object deals with the permission on the Blank application, on the 'system' level
# and on the 'workspace' level (according to the value set on the 'type_permission' attribute).
#
class Permission < ActiveRecord::Base
  
  # Relation N-N with the 'roles' table
  has_and_belongs_to_many :roles
  # Validation of the presence of these attributes
  validates_presence_of :name, :type_permission
	# Validation of the uniqueness of this attribute
  validates_uniqueness_of :name

  named_scope :type_of, lambda {|type_permission|
    {
      :conditions => {:type_permission => type_permission},
      :order => "name ASC"
    }
  }

end
